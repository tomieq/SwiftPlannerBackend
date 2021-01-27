//
//  InputDto.swift
//  
//
//  Created by Tomasz Kucharski on 23/12/2020.
//

import Foundation

class InputDto: Codable {
    var daysInMonth: Int?
    var workplaces: [WorkplaceDto]?
    var users: [UserDto]?
    
    enum CodingKeys: String, CodingKey {
        case daysInMonth
        case workplaces = "workPlaces"
        case users
    }
}


extension InputDto: CustomDebugStringConvertible {
    var debugDescription: String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        if let jsonData = try? jsonEncoder.encode(self) {
            return String(decoding: jsonData, as: UTF8.self)
        }
        return "nil"
    }
}
