//
//  WishDto.swift
//  
//
//  Created by Tomasz Kucharski on 28/12/2020.
//

import Foundation

enum WishType: String, Codable {
    case and
    case or
    case preferredDays
    case workPlaceLimitation
}

class WishDto: Codable {
    var type: WishType?
    var amount: Int?
    var days: [Int]?
    var workPlaceID: Int?
    var rules: [WishRuleDto]?
}

class WishRuleDto: Codable {
    var amount: Int?
    var days: [Int]?
}
