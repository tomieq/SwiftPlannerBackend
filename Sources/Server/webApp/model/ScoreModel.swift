//
//  ScoreModel.swift
//  
//
//  Created by Tomasz Kucharski on 04/01/2021.
//

import Foundation

class ScoreModel: Codable {
    var scheduledDays: Int
    var preferredDays: Int
    
    init(scheduledDays: Int, preferredDays: Int) {
        self.scheduledDays = scheduledDays
        self.preferredDays = preferredDays
    }
}
