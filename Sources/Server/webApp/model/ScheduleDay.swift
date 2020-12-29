//
//  ScheduleDay.swift
//  
//
//  Created by Tomasz Kucharski on 29/12/2020.
//

import Foundation

class ScheduleDay: Codable {
    let dayNumber: Int
    var selectedUser: ScheduleUser?
    var availableUsers: [ScheduleUser]
    
    init(dayNumber: Int, availableUsers: [ScheduleUser], selectedUser: ScheduleUser? = nil) {
        self.dayNumber = dayNumber
        self.availableUsers = availableUsers
        self.selectedUser = selectedUser
    }
}
