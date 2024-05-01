//
//  ParkingRate.swift
//  SmartParking
//
//  Created by Deependra Dhakal on 11/6/22.
//

import Foundation

struct ParkingPrice: Codable{
    var halfHour : Int
    var halfToOneHour : Int
    var oneToTwoHour : Int
    var twoToThreeHour : Int
    var threeToFourHour : Int
    var fourToTwentyFourHour : Int
    
    enum CodingKeys: String, CodingKey {
        case halfHour = "half_hour"
        case halfToOneHour = "half_to_one_hour"
        case oneToTwoHour = "one_to_two_hour"
        case twoToThreeHour = "two_to_three_hour"
        case threeToFourHour = "three_to_four_hour"
        case fourToTwentyFourHour = "four_to_twentyfour_hour"
    }
}
