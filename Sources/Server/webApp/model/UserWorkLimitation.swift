//
//  UserWorkLimitation.swift
//  
//
//  Created by Tomasz Kucharski on 29/12/2020.
//

import Foundation

class UserWorkLimitation: Codable {
    var dayLimit: Int
    var dayNumbers: [Int]
    
    init?(from dto: WishDto) {
        guard let dayLimit = dto.amount, let dayNumbers = dto.days else {
            return nil
        }
        self.dayLimit = dayLimit
        self.dayNumbers = dayNumbers
    }
    
    init?(from dto: WishRuleDto) {
        guard let dayLimit = dto.amount, let dayNumbers = dto.days else {
            return nil
        }
        self.dayLimit = dayLimit
        self.dayNumbers = dayNumbers
    }
    
    init(from snapshot: UserWorkLimitationSnapshot) {
        self.dayLimit = snapshot.dayLimit
        self.dayNumbers = snapshot.dayNumbers
    }
}
