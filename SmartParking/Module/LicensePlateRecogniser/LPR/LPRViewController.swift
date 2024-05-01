//
//  LPRViewController.swift
//  LicensePlateRecognition
//
//  Created by Shawn Gee on 9/19/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import IBAnimatable
import Lottie
import ToastViewSwift

enum CameraState {
    case parkIn, parkOut
    
    var description: String {
        switch self {
        case .parkOut:
            return "Park out mode activated"
        case .parkIn:
            return "Park in mode activated"
        }
    }
}

class LPRViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var bufferSize: CGSize = .zero
    
    // MARK: - Private Properties
    
    @IBOutlet private var lprView: LPRView!
    @IBOutlet private var stateView: AnimatableView!
    @IBOutlet private var priceParentView: AnimatableView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var lottieView: LottieAnimationView!
    
    private let captureSession = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput",
                                                     qos: .userInitiated,
                                                     attributes: [],
                                                     autoreleaseFrequency: .workItem)
    private let photoOutput = AVCapturePhotoOutput()
    private var requests = [VNRequest]()
    private let readPlateNumberQueue = OperationQueue()
    private let licensePlateController = LicensePlateController()
    
    private var pauseScanning: Bool = false
    
    private var cameraState: CameraState = .parkIn
    
    private var currentState: ParkingState = .scanMode {
        didSet {
            setStateView(currentState)
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Smart Parking"
        navigationController?.setTheme(theme: .whiteTheme())
        addParkingRateNavigator()
        setUp()
        priceParentView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
        currentState = .scanMode
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    // MARK: - Private Methods
    private func addParkingRateNavigator() {
        let rateBarButton = UIBarButtonItem(image: UIImage(systemName: "dollarsign.square.fill"), style: .plain, target: self, action: #selector(parkingRateTapped))
        navigationItem.rightBarButtonItem = rateBarButton
        
        let registerCarBarButton = UIBarButtonItem(image: UIImage(systemName: "car.fill"), style: .plain, target: self, action: #selector(registerCarTapped))
        navigationItem.leftBarButtonItem = registerCarBarButton
        
        //Add park in out switch
        let offLabel = UILabel()
        offLabel.font = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)
        offLabel.text = "In"
        offLabel.textColor = .white
        
        let onLabel = UILabel()
        onLabel.font = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)
        onLabel.text = "Out"
        onLabel.textColor = .white
        
        let toggle = UISwitch()
        toggle.onTintColor = .uhDark
        toggle.set(offTint: .uhDark)
        
        toggle.addTarget(self, action: #selector(toggleValueChanged(_:)), for: .valueChanged)
        
        let stackView = UIStackView(arrangedSubviews: [offLabel, toggle, onLabel])
        stackView.spacing = 8
        
        navigationItem.titleView = UIBarButtonItem(customView: stackView).customView
    }
    
    
    @objc func toggleValueChanged(_ toggle: UISwitch) {
        cameraState = toggle.isOn ? .parkOut : .parkIn
        
        let toastView = Toast.text(cameraState.description)
        toastView.show()
    }
    
    @objc private func parkingRateTapped() {
        navigateTo(route: .parkingRates)
    }
    
    @objc private func registerCarTapped() {
        navigateTo(route: .registerCar)
    }
    
    private func setUp() {
        lprView.videoPlayerView.videoGravity = .resizeAspectFill
        setUpAVCapture()
        try? setUpVision()
    }
    
    private func setUpAVCapture() {
        var deviceInput: AVCaptureDeviceInput!
        
        // Select a video device, make an input
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        captureSession.beginConfiguration()
        
        captureSession.sessionPreset = .vga640x480 // Model image size is smaller.
        
        // Add a video input
        guard captureSession.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            captureSession.commitConfiguration()
            return
        }
        captureSession.addInput(deviceInput)
        
        // Add video output
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
            // Add a video data output
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            captureSession.commitConfiguration()
            return
        }
        
        let captureConnection = videoDataOutput.connection(with: .video)
        // Always process the frames
        captureConnection?.isEnabled = true
        
        // Get buffer size to allow for determining recognized license plate positions
        // relative to the video ouput buffer size
        do {
            try videoDevice!.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice!.unlockForConfiguration()
        } catch {
            print(error)
        }
        
        // Add photo output
        if captureSession.canAddOutput(photoOutput) {
            photoOutput.isHighResolutionCaptureEnabled = true
            captureSession.addOutput(photoOutput)
        }
        
        captureSession.commitConfiguration()
        
        lprView.bufferSize = bufferSize
        lprView.session = captureSession
    }
    
    private func setUpVision() throws {
        let visionModel = try VNCoreMLModel(for: LicensePlateDetector_v1().model)
        
        let objectRecognition = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
            guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
            self?.processResults(results)
        }
        
        self.requests = [objectRecognition]
    }
    
    private func processResults(_ results: [VNRecognizedObjectObservation]) {
        let rects = results.map {
            VNImageRectForNormalizedRect($0.boundingBox,
                                         Int(bufferSize.width),
                                         Int(bufferSize.height))
        }
        
        licensePlateController.updateLicensePlates(withRects: rects)
        
        // perform drawing on main thread
        DispatchQueue.main.async {
            self.lprView.licensePlates = self.licensePlateController.licensePlates
        }
        if !self.pauseScanning {
            getPlateNumber()
        }
    }
    
    /// If there aren't any operations currently going, attempt to get the plate number
    /// for the first plate without a number in the license plate controller.
    private func getPlateNumber() {
        guard let firstPlate = licensePlateController.licensePlatesWithoutNumbers.first,
              readPlateNumberQueue.operationCount == 0 else {
            return
        }
        
        let rect = firstPlate.lastRectInBuffer
        let regionOfInterest = CGRect(x: rect.minX / bufferSize.width,
                                      y: rect.minY / bufferSize.height,
                                      width: rect.width / bufferSize.width,
                                      height: rect.height / bufferSize.height)
        
        let readPlateNumberOperation = ReadPlateNumberOperation(region: regionOfInterest)
        { [weak self] number in
            if let number = number {
                self?.licensePlateController.addNumber(number, to: firstPlate)
                
                self?.parkInOut(plateNumber: number)
            }
        }
        
        readPlateNumberQueue.addOperation(readPlateNumberOperation)
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = true
        photoOutput.capturePhoto(with: photoSettings,
                                 delegate: readPlateNumberOperation.capturePhotoOperation)
    }
    
    private func parkInOut(plateNumber: String) {
        
        if cameraState == .parkIn {
            
            API.shared.parkVehicle(licensePlateNumber: plateNumber) { result, error in
                self.pauseScanning = true
                switch result {
                case .parkedIn:
                    self.currentState = .parkedIn
                case .parkingInValidUser:
                    self.currentState = .parkingInValidUser
                case .parkingInGuestUser:
                    self.currentState = .parkingInGuestUser
                default:
                    print(error ?? "")
                }
            }
            
        }else {
            API.shared.parkOutVehicle(licensePlateNumber: plateNumber) { model, state, status, error in
                self.pauseScanning = true
                
                if let isValidUser = status, isValidUser {
                    self.currentState = .parkingOutValidUser
                    
                }else if let timestamp = model?.timestamp, let isValidUser = model?.isRegistered, !isValidUser {
                    let (hoursParked, minutesParked) = API.shared.calculateParkedHours(inTime: timestamp)
                    API.shared.getParkingRates {[weak self] rates, error in
                        guard let `self` = self else {return}
                        print(error ?? "")
                        
                        self.priceParentView.isHidden = false
                        
                        if hoursParked == 0 && minutesParked <= 30 {
                            self.priceLabel.text = "$\(rates?.halfHour ?? 0)"
                            self.hoursLabel.text = "\(minutesParked) mins"
                        }else if hoursParked <= 1 {
                            self.priceLabel.text = "$\(rates?.halfToOneHour ?? 0)"
                            self.hoursLabel.text = "\(hoursParked) hour"
                        }else if hoursParked <= 2 {
                            self.priceLabel.text = "$\(rates?.oneToTwoHour ?? 0)"
                            self.hoursLabel.text = "\(hoursParked) hours"
                        }else if hoursParked <= 3 {
                            self.priceLabel.text = "$\(rates?.twoToThreeHour ?? 0)"
                            self.hoursLabel.text = "\(hoursParked) hours"
                        }else if hoursParked <= 4 {
                            self.priceLabel.text = "$\(rates?.threeToFourHour ?? 0)"
                            self.hoursLabel.text = "\(hoursParked) hours"
                        }else {
                            self.priceLabel.text = "$\(rates?.fourToTwentyFourHour ?? 0)"
                            self.hoursLabel.text = "\(hoursParked) hours"
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                            self.priceParentView.isHidden = true
                            self.currentState = .parkingOutGuestUser
                        })
                    }
                    
                }else if state == .notInParking {
                    self.currentState = .notInParking
                }
            }
        }
        
        
    }
    
    private func setStateView(_ newState: ParkingState) {
        UIView.animate(withDuration: 1, animations: {
            self.stateView.backgroundColor = newState.stateColor.withAlphaComponent(0.2)
            self.stateView.shadowColor = newState.stateColor
            self.descriptionLabel.text = newState.stateDescription
            self.descriptionLabel.textColor = newState.stateColor
        })
        
        playLottieAniamation(newState)
    }
    
    private func playLottieAniamation(_ state: ParkingState) {
        let jsonName = state.stateAnimation
        let animation = LottieAnimation.named(jsonName)
        
        // Load animation to AnimationView
        lottieView.animation = animation
        lottieView.backgroundBehavior = .pauseAndRestore
        lottieView.loopMode = .playOnce
        lottieView.animationSpeed = 0.5
        
        // Play the animation
        lottieView.play { complete in
            if complete {
                switch state {
                    
                case .scanMode, .parked, .checkout, .parkedIn, .parkedOut:
                    self.pauseScanning = false
                    self.currentState = .scanMode
                    self.lottieView.animationSpeed = 1
                case .parkingInValidUser:
                    self.currentState = .parked
                    self.lottieView.animationSpeed = 1
                case .parkingInGuestUser:
                    self.currentState = .parked
                    self.lottieView.animationSpeed = 1
                case .parkingOutValidUser:
                    self.currentState = .parkedOut
                    self.lottieView.animationSpeed = 1
                case .parkingOutGuestUser:
                    self.currentState = .checkout
                    self.lottieView.animationSpeed = 1
                case .notInParking:
                    self.currentState = .scanMode
                    self.lottieView.animationSpeed = 1
                }
            }
        }
        
    }
}

// MARK: - Video Data Output Delegate

extension LPRViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                        orientation: .currentRearCameraOrientation,
                                                        options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput,
                       didDrop didDropSampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        // print("frame dropped")
    }
}
