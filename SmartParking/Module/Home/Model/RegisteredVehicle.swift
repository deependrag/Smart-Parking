//
//  RegisteredVehicle.swift
//  SmartParking
//
//  Created by Deependra Dhakal on 11/6/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct RegisteredVehicle: Codable{
    var licensePlate : String
    var name : String
    var registered : Timestamp
    var valid : String
}
