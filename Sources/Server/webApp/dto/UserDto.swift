//
//  UserDto.swift
//  
//
//  Created by Tomasz Kucharski on 23/12/2020.
//

import Foundation

class UserDto: Codable {
    var id: Int?
    var name: String?
    var maxWorkingDays: Int?
    var possibleDays: [Int]?
    var impossibleDays: [Int]?
    var wantedDays: [Int]?
    var allowedWorkplaceIDs: [Int]?
    var wishes: [WishDto]?
}
