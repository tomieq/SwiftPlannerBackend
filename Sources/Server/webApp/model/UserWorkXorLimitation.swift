//
//  UserWorkXorLimitation.swift
//  
//
//  Created by Tomasz Kucharski on 29/12/2020.
//

import Foundation

class UserWorkXorLimitation: Codable {
    var rules: [UserWorkLimitation]
    
    init(rules: [UserWorkLimitation]) {
        self.rules = rules
    }
    
    func contains(dayNumber: Int) -> Bool {
        for rule in self.rules {
            if rule.dayNumbers.contains(dayNumber) {
                return true
            }
        }
        return false
    }
}
