//
//  API.swift
//  SmartParking
//
//  Created by Deependra Dhakal on 11/6/22.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class API {
    static var shared = API()
    
    private let db = Firestore.firestore()
    
    // MARK: Get Parking rates from the firebase
    func getParkingRates(parkingRates: (@escaping (ParkingPrice?, String?) -> Void)){
        
        db.collection(GUEST_PARKING).document(PRICE).addSnapshotListener({ document, error in
            if error == nil {
                let model = try? document?.data(as: ParkingPrice.self)
                parkingRates(model, nil)
            }else {
                parkingRates(nil, error?.localizedDescription)
            }
        })
        
    }
    
    //MARK: Check if the vehicle has valid permit
    func checkValidPermit(licensePlateNumber: String, result: (@escaping (Bool?, String?) -> Void)) {
        
        db.collection(REGISTERED).getDocuments(completion: { querySnapshots, error in
            
            if error == nil {
                let model = querySnapshots?.documents.compactMap { queryDocumentSnapshot -> RegisteredVehicle? in
                    return try? queryDocumentSnapshot.data(as: RegisteredVehicle.self)
                }
                
                result(model?.contains(where: {$0.licensePlate == licensePlateNumber}), error?.localizedDescription)
            }else {
                result(nil, error?.localizedDescription)
            }
        })
    }
    //MARK: Get all parked vehicles
    func getAllParkedVehicles(result: (@escaping ([ParkModel]?, String?) -> Void)) {
        db.collection(LIVE_PARKING).document(INSIDE_GARAGE).getDocument { documentSnapshot, error in
            if error == nil {
                let model = try? documentSnapshot?.data(as: ParkedVehiclesModel.self)
                
                result(model?.vehicles, error?.localizedDescription)
            }else {
                result(nil, error?.localizedDescription)
            }
        }
    }
    
    //MARK: Check if vehicle is inside the garage
    func checkIfVehicleInsideGarage(licensePlateNumber: String, result: (@escaping (Bool?, String?) -> Void)) {
        
        getAllParkedVehicles { model, error in
            result(model?.contains{$0.plateNumber == licensePlateNumber}, error)
        }
    }
    
    
    //MARK: Park in the vehicle
    func parkVehicle(licensePlateNumber: String, result: (@escaping (ParkingState?, String?) -> Void)) {
        
        //Check if vehicle is inside the garage
        checkIfVehicleInsideGarage(licensePlateNumber: licensePlateNumber) {[weak self] isInside, _ in
            
            if isInside != true {
                
                //Check if license plate is registered in server
                self?.checkValidPermit(licensePlateNumber: licensePlateNumber) {[weak self] isValidPermit, _ in
                    
                    let model = ParkModel(
                        id: UUID().uuidString,
                        isRegistered: isValidPermit ?? false,
                        plateNumber: licensePlateNumber,
                        timestamp: Timestamp()
                    )
                    
                    self?.db.collection(LIVE_PARKING)
                        .document(INSIDE_GARAGE)
                        .setData([VEHICLES: FieldValue.arrayUnion([try! model.asDictionary()])], merge: true)
                    
                    result(
                        isValidPermit ?? false ?
                            .parkingInValidUser :
                                .parkingInGuestUser,
                        nil
                    )
                    
                }
                
            }else {
                result(.parkedIn, "\(licensePlateNumber) Vehicle already inside the garage")
            }
        }
    }
    
    //MARK: Register Vehicle
    func registerVehicle(model: RegisteredVehicle, result: (@escaping (Bool?, String?) -> Void)) {
        self.db.collection(REGISTERED)
            .document()
            .setData(try! model.asDictionary(), merge: true) { error in
                if error != nil {
                    result(false, error?.localizedDescription)
                }else {
                    result(true, nil)
                }
                
            }
        
    }
    
    
    //MARK: Park out the vehicle
    func parkOutVehicle(licensePlateNumber: String, result: (@escaping (ParkModel?, ParkingState?, Bool?, String?) -> Void)) {
        //Check if license plate is registered in server
        checkValidPermit(licensePlateNumber: licensePlateNumber) {[weak self] isValidPermit, err in
            
            self?.getAllParkedVehicles { model, error in
                
                if let parkModel = model?.first(where: {$0.plateNumber == licensePlateNumber}) {
                    
                    if isValidPermit ?? false {
                        result(nil, nil, true, err)
                    }
                    
                    let finalModel = model!.filter{$0.plateNumber != licensePlateNumber}.map{try! $0.asDictionary()}
                    
                    self?.db.collection(LIVE_PARKING)
                        .document(INSIDE_GARAGE)
                        .setData([VEHICLES: finalModel], merge: true)
                    
                    result(parkModel, nil,  nil, error)
                    
                }else {
                    result(nil, .notInParking,nil, nil)
                }
                
            }
        }
    }
    
    func calculateParkedHours(inTime: Timestamp) -> (Int, Int) {
        let currentTime = Date()
        let innTime = inTime.dateValue()
        let components = Calendar.current.dateComponents([.hour, .minute], from: innTime, to: currentTime)
        return (components.hour ?? 0, components.minute ?? 0)
    }
}


enum ParkingState {
    case scanMode,
         parked,
         parkedOut,
         parkingInValidUser,
         parkingInGuestUser,
         parkingOutValidUser,
         parkingOutGuestUser,
         checkout,
         parkedIn,
         notInParking
    
    var stateColor: UIColor {
        switch self {
        case .scanMode:
            return .colorLightOrange
        case .parked:
            return .colorBlue
        case .parkedOut:
            return .colorBlue
        case .parkingInValidUser:
            return .colorGreen
        case .parkingInGuestUser:
            return .colorGreen
        case .parkingOutValidUser:
            return .colorGreen
        case .parkingOutGuestUser:
            return .colorGreen
        case .checkout:
            return .colorGreen
        case .parkedIn:
            return .colorBlue
        case .notInParking:
            return .colorBlue
        }
    }
    
    var stateAnimation: String {
        switch self {
        case .scanMode:
            return "scan_license_plate"
        case .parked, .parkedOut:
            return "check_mark"
        case .parkingInValidUser:
            return "car_moving"
        case .parkingInGuestUser:
            return "car_moving"
        case .parkingOutValidUser:
            return "car_moving"
        case .parkingOutGuestUser:
            return "car_moving"
        case .checkout:
            return "card_success"
        case .parkedIn:
            return "parked"
        case .notInParking:
            return "car_moving"
        }
    }
    
    var stateDescription: String {
        switch self {
        case .scanMode:
            return "Scanning"
        case .parked:
            return "Vehicle Parked In"
        case .parkedOut:
            return "Vehicle Parked Out"
        case .parkingInValidUser:
            return "Parking In (Valid Permit)"
        case .parkingInGuestUser:
            return "Parking In (Guest)"
        case .parkingOutValidUser:
            return "Parking Out (Valid Permit)"
        case .parkingOutGuestUser:
            return "Parking Out (Guest)"
        case .checkout:
            return "Checkout Success"
        case .parkedIn:
            return "Vehicle in Parking"
        case .notInParking:
            return "Not in parking"
        }
    }
}
