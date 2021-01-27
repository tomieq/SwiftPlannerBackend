//
//  ScheduleWorkplace.swift
//  
//
//  Created by Tomasz Kucharski on 29/12/2020.
//

import Foundation

class ScheduleWorkplace: Codable {
    let id: Int
    let name: String
    let scheduleDays: [ScheduleDay]
    
    init(id: Int, name: String, scheduleDays: [ScheduleDay]) {
        self.id = id
        self.name = name
        self.scheduleDays = scheduleDays
    }
    
    init(from snapshot: ScheduleWorkplaceSnapshot) {
        self.id = snapshot.id
        self.name = snapshot.name
        self.scheduleDays = snapshot.scheduleDays.map { ScheduleDay(from: $0) }
    }
}
