//
//  ScheduleDay.swift
//  
//
//  Created by Tomasz Kucharski on 29/12/2020.
//

import Foundation

enum ScheduleError: Error {
    case invalidAssigmentError(String)
}

class ScheduleDay: Codable {
    let dayNumber: Int
    var selectedUser: ScheduleUser?
    var availableUsers: [ScheduleUser]
    
    init(dayNumber: Int, availableUsers: [ScheduleUser]) {
        self.dayNumber = dayNumber
        self.availableUsers = availableUsers
        self.selectedUser = nil
    }
    
    init(from snapshot: ScheduleDaySnapshot) {
        self.dayNumber = snapshot.dayNumber
        self.selectedUser = ScheduleUser(from: snapshot.selectedUser)
        self.availableUsers = snapshot.availableUsers.compactMap{ ScheduleUser(from: $0) }
    }
    
    func assign(user: ScheduleUser) throws {
        if let selectedUser = (self.availableUsers.filter{ $0.id == user.id }.first) {
            self.selectedUser = selectedUser
            self.availableUsers = []
            return
        }
        throw ScheduleError.invalidAssigmentError("User \(user.name) is not allowed to work here on \(self.dayNumber.ordinal)!")
    }
    
    var isScheduled: Bool {
        return self.selectedUser != nil
    }
}
