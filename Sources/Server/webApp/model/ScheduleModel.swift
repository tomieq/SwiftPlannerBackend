//
//  ScheduleModel.swift
//  
//
//  Created by Tomasz Kucharski on 25/12/2020.
//

import Foundation

class ScheduleModel: Codable {
    
    let workplaces: [ScheduleWorkplace]
    var users: [User]
    
    init(workplaces: [ScheduleWorkplace], users: [User]) {
        self.workplaces = workplaces
        self.users = users
    }
    
    func assign(user: ScheduleUser, on dayNumber: Int, to workplace: ScheduleWorkplace) {
        self.workplaces.filter { $0.id == workplace.id }.first?.scheduleDays.filter { $0.dayNumber == dayNumber }.first?.selectedUser = user
    
    func remove(user: User) {
        self.remove(userID: user.id)
    }
    
    func remove(user: ScheduleUser) {
        self.remove(userID: user.id)
    }
    
    private func remove(userID: Int) {
        self.users = self.users.filter { $0.id != userID }
        self.workplaces.forEach { workplace in
            workplace.scheduleDays.forEach { scheduleDay in
                scheduleDay.availableUsers = scheduleDay.availableUsers.filter { $0.id != userID }
            }
        }
    }
}

extension ScheduleModel: CustomDebugStringConvertible {
    var debugDescription: String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        if let jsonData = try? jsonEncoder.encode(self) {
            return String(decoding: jsonData, as: UTF8.self)
        }
        return "nil"
    }
}

class ScheduleWorkplace: Codable {
    let id: Int
    let name: String
    let scheduleDays: [ScheduleDay]
    
    init(id: Int, name: String, scheduleDays: [ScheduleDay]) {
        self.id = id
        self.name = name
        self.scheduleDays = scheduleDays
    }
}

class ScheduleDay: Codable {
    let dayNumber: Int
    var selectedUser: ScheduleUser?
    let availableUsers: [ScheduleUser]
    
    init(dayNumber: Int, availableUsers: [ScheduleUser]) {
        self.dayNumber = dayNumber
        self.availableUsers = availableUsers
    }
}

struct ScheduleUser: Codable {
    let id: Int
    let name: String
    let workplacePriority: Int
    let assignmantLevel: AssignmaneLevel
    let otherWorkplaceIDs: [Int]
}

enum AssignmaneLevel: String, Codable {
    case wantedDay
    case possibleDay
}


class User: Codable {
    let id: Int
    let name: String
    let wantedDayNumbers: [Int]
    let possibleDayNumbers: [Int]
    let workPlaceIDs: [Int]
    var maxWorkingDays: Int
    
    init(id: Int, name: String, wantedDayNumbers: [Int], possibleDayNumbers: [Int], workPlaceIDs: [Int], maxWorkingDays: Int) {
        self.id = id
        self.name = name
        self.wantedDayNumbers = wantedDayNumbers
        self.possibleDayNumbers = possibleDayNumbers
        self.workPlaceIDs = workPlaceIDs
        self.maxWorkingDays = maxWorkingDays
    }
}
