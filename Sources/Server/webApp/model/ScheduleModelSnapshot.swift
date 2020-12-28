//
//  ScheduleModelSnapshot.swift
//  
//
//  Created by Tomasz Kucharski on 28/12/2020.
//

import Foundation

struct ScheduleModelSnapshot {
    let versionNumber: Int
    let plannedDays: Int
    let daysLeftToPlan: Int
    let users: [UserSnapshot]
    let workplaces: [ScheduleWorkplaceSnapshot]
}

struct ScheduleWorkplaceSnapshot {
    let id: Int
    let name: String
    let scheduleDays: [ScheduleDaySnapshot]
}

struct ScheduleDaySnapshot {
    let dayNumber: Int
    let selectedUser: ScheduleUserSnapshot?
    let availableUsers: [ScheduleUserSnapshot]
}

struct ScheduleUserSnapshot {
    let id: Int
    let name: String
    let workplacePriority: Int
    let assignmantLevel: AssignmaneLevel
    let otherWorkplaceIDs: [Int]
}


struct UserSnapshot {
    let id: Int
    let name: String
    let wantedDayNumbers: [Int]
    let possibleDayNumbers: [Int]
    let workPlaceIDs: [Int]
    let maxWorkingDays: Int
}