//
//  ScheduleUser.swift
//  
//
//  Created by Tomasz Kucharski on 29/12/2020.
//

import Foundation


enum AssignmaneLevel: String, Codable {
    case wantedDay
    case possibleDay
}

class ScheduleUser: Codable {
    let id: Int
    let name: String
    let workplacePriority: Int
    let assignmantLevel: AssignmaneLevel
    var otherWorkplaceIDs: [Int]
    
    init(id: Int, name: String, workplacePriority: Int, assignmantLevel: AssignmaneLevel, otherWorkplaceIDs: [Int]) {
        self.id = id
        self.name = name
        self.workplacePriority = workplacePriority
        self.assignmantLevel = assignmantLevel
        self.otherWorkplaceIDs = otherWorkplaceIDs
    }
    
    init?(from snapshot: ScheduleUserSnapshot?) {
        guard let snapshot = snapshot else {
            return nil
        }
        self.id = snapshot.id
        self.name = snapshot.name
        self.workplacePriority = snapshot.workplacePriority
        self.assignmantLevel = snapshot.assignmantLevel
        self.otherWorkplaceIDs = snapshot.otherWorkplaceIDs
    }
}
