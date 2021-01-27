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
    
    init() {
        self.scheduledDays = 0
        self.preferredDays = 0
    }
    
    init(from snapshot: ScoreModelSnapshot) {
        self.scheduledDays = snapshot.scheduledDays
        self.preferredDays = snapshot.preferredDays
    }
}

extension ScoreModel: Comparable {
    static func < (lhs: ScoreModel, rhs: ScoreModel) -> Bool {
        if lhs.scheduledDays == rhs.scheduledDays {
            return lhs.preferredDays < rhs.preferredDays
        }
        return lhs.scheduledDays < rhs.scheduledDays
    }
    
    static func == (lhs: ScoreModel, rhs: ScoreModel) -> Bool {
        if lhs.scheduledDays != rhs.scheduledDays {
            return false
        }
        if lhs.preferredDays != rhs.preferredDays {
            return false
        }
        return true
    }
    
    
}
