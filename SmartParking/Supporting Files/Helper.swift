//
//  Helper.swift
//  SmartParking
//
//  Created by Deependra Dhakal on 11/12/22.
//

import Foundation

class Helper {
    class func getTodaysDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter.string(from: Date())
    }
}
