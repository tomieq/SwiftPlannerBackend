//
//  WorkplaceDto.swift
//  
//
//  Created by Tomasz Kucharski on 23/12/2020.
//

import Foundation

class WorkplaceDto: Codable {
    var id: Int?
    var name: String?
    var allowedUsers: [UserWithPriority]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case id = "id"
        case allowedUsers
    }
}

extension WorkplaceDto: CustomDebugStringConvertible {
    var debugDescription: String {
        return "WorkPlaceDto { id = \(self.id ?? 0), name = \(self.name ?? "nil") }"
    }
}
