//
//  ScheduleModel.swift
//  
//
//  Created by Tomasz Kucharski on 25/12/2020.
//

import Foundation

class ScheduleModel: Codable {
    
    let workplaces: [ScheduleWorkplace]
    
    init(workplaces: [ScheduleWorkplace]) {
        self.workplaces = workplaces
    }
    
    func assign(user: ScheduleUser, on dayNumber: Int, to workplace: ScheduleWorkplace) {
        self.workplaces.filter { $0.id == workplace.id }.first?.scheduleDays.filter { $0.dayNumber == dayNumber }.first?.selectedUser = user
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
