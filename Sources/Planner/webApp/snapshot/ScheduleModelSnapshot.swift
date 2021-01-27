//
//  ScheduleModelSnapshot.swift
//  
//
//  Created by Tomasz Kucharski on 28/12/2020.
//

import Foundation

struct ScheduleModelSnapshot {
    let versionNumber: Int
    let daysLeftToPlan: Int
    let users: [UserSnapshot]
    let workplaces: [ScheduleWorkplaceSnapshot]
    let score: ScoreModelSnapshot
}

struct ScheduleWorkplaceSnapshot {
    let id: Int
    let name: String
    let scheduleDays: [ScheduleDaySnapshot]
    
    init(from model: ScheduleWorkplace) {
        self.id = model.id
        self.name = model.name
        self.scheduleDays = model.scheduleDays.map { ScheduleDaySnapshot(from: $0) }
    }
}

struct ScheduleDaySnapshot {
    let dayNumber: Int
    let selectedUser: ScheduleUserSnapshot?
    let availableUsers: [ScheduleUserSnapshot]
    
    init(from model: ScheduleDay) {
        self.dayNumber = model.dayNumber
        self.selectedUser = ScheduleUserSnapshot(from: model.selectedUser)
        self.availableUsers = model.availableUsers.compactMap { ScheduleUserSnapshot(from: $0) }
    }
}

struct ScheduleUserSnapshot {
    let id: Int
    let name: String
    let workplacePriority: Int
    let assignmantLevel: AssignmaneLevel
    let otherWorkplaceIDs: [Int]
    
    init?(from model: ScheduleUser?) {
        guard let model = model else {
            return nil
        }
        self.id = model.id
        self.name = model.name
        self.workplacePriority = model.workplacePriority
        self.assignmantLevel = model.assignmantLevel
        self.otherWorkplaceIDs = model.otherWorkplaceIDs
    }
}


struct UserSnapshot {
    let id: Int
    let name: String
    let wantedDayNumbers: [Int]
    let possibleDayNumbers: [Int]
    let workPlaceIDs: [Int]
    let wishes: UserWishesSnapshot
    let maxWorkingDays: Int
    
    init(from model: User) {
        self.id = model.id
        self.name = model.name
        self.wantedDayNumbers = model.wantedDayNumbers
        self.possibleDayNumbers = model.possibleDayNumbers
        self.workPlaceIDs = model.workPlaceIDs
        self.maxWorkingDays = model.maxWorkingDays
        self.wishes = UserWishesSnapshot(from: model.wishes)
    }
}

struct UserWishesSnapshot {
    let workingDayLimitations: [UserWorkLimitationSnapshot]
    let workindDayXorLimitations: [UserWorkXorLimitationSnapshot]
    
    init(from model: UserWishes) {
        self.workingDayLimitations = model.workingDayLimitations.map { UserWorkLimitationSnapshot(from: $0) }
        self.workindDayXorLimitations = model.workindDayXorLimitations.map { UserWorkXorLimitationSnapshot(from: $0) }
    }
}

struct UserWorkLimitationSnapshot {
    let dayLimit: Int
    let dayNumbers: [Int]
    var scorePoints: Int
    
    init(from model: UserWorkLimitation) {
        self.dayLimit = model.dayLimit
        self.dayNumbers = model.dayNumbers
        self.scorePoints = model.scorePoints
    }
}

struct UserWorkXorLimitationSnapshot {
    let rules: [UserWorkLimitationSnapshot]
    
    init(from model: UserWorkXorLimitation) {
        self.rules = model.rules.map{ UserWorkLimitationSnapshot(from: $0) }
    }
}

struct ScoreModelSnapshot {
    let scheduledDays: Int
    let preferredDays: Int
    
    init(from model: ScoreModel) {
        self.scheduledDays = model.scheduledDays
        self.preferredDays = model.preferredDays
    }
}
