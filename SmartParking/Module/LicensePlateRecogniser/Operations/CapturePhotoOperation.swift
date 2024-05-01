//
//  CapturePhotoOperation.swift
//  LicensePlateRecognition
//
//  Created by Shawn Gee on 9/20/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import AVFoundation
import UIKit

class CapturePhotoOperation: ConcurrentOperation, AVCapturePhotoCaptureDelegate {
    var cgImage: CGImage?
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        defer { finish() }
        
        if let error = error {
            print(error)
            return
        }
        let uiimage = UIImage(data: photo.fileDataRepresentation() ?? Data())
        
        guard let image = uiimage?.cgImage else {
            return
        }
        
        cgImage = image
    }
}

