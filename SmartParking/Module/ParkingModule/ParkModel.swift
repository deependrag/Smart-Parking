//
//  ParkModel.swift
//  SmartParking
//
//  Created by Deependra Dhakal on 11/12/22.
//

import Foundation
import FirebaseFirestore


struct ParkModel: Codable{
    var id: String = ""
    var isRegistered : Bool
    var plateNumber : String
    var timestamp : Timestamp
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case isRegistered = "is_registered"
        case plateNumber = "plate_number"
        case timestamp = "timestamp"
    }
}

struct ParkedVehiclesModel: Codable{
    var vehicles: [ParkModel]
}
