//
//  UserWishes.swift
//  
//
//  Created by Tomasz Kucharski on 29/12/2020.
//

import Foundation

class UserWishes: Codable {
    var workingDayLimitations: [UserWorkLimitation]
    var workindDayXorLimitations: [UserWorkXorLimitation]
    
    init(workingDayLimitations: [UserWorkLimitation], workindDayXorLimitations: [UserWorkXorLimitation]) {
        self.workingDayLimitations = workingDayLimitations
        self.workindDayXorLimitations = workindDayXorLimitations
    }
    
    func xorLimitationContains(dayNumber: Int) -> Bool {
        for alternative in self.workindDayXorLimitations {
            for rule in alternative.rules {
                if rule.dayNumbers.contains(dayNumber) {
                    return true
                }
            }
        }
        return false
    }
}
