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
    
    init(dayLimit: Int, dayNumbers: [Int]) {
        self.dayLimit = dayLimit
        self.dayNumbers = dayNumbers
    }
}
