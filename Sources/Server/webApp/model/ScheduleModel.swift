//
//  ScheduleModel.swift
//  
//
//  Created by Tomasz Kucharski on 25/12/2020.
//

import Foundation

struct ScheduleModel: Codable {
    let workplaces: [ScheduleWorkplace]
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

struct ScheduleWorkplace: Codable {
    let id: Int
    let name: String
    let days: [ScheduleDay]
}

struct ScheduleDay: Codable {
    let dayNumber: Int
    var selectedUser: ScheduleUser?
    let availableUsers: [ScheduleUser]
}

struct ScheduleUser: Codable {
    let id: Int
    let name: String
    let workplacePriority: Int
    let assignmantLevel: AssignmaneLevel
}

enum AssignmaneLevel: String, Codable {
    case wantedDay
    case possibleDay
}
