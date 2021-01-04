//
//  ScoreModel.swift
//  
//
//  Created by Tomasz Kucharski on 04/01/2021.
//

import Foundation

class ScoreModel: Codable {
    var preferredDays: Int
    
    init(preferredDays: Int) {
        self.preferredDays = preferredDays
    }
}
