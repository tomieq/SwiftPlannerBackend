//
//  ModelBuilder.swift
//  
//
//  Created by Tomasz Kucharski on 25/12/2020.
//

import Foundation

class ModelBuilder {
    static func makeModel(from dto: InputDto) -> ScheduleModel? {
        
        guard let daysInMonth = dto.daysInMonth else {
            Logger.error("Input data","Missing daysInMonth value.")
            return nil
        }
        
        var workplaces: [ScheduleWorkplace] = []
        dto.workplaces?.forEach { workplace in
            if workplace.allowedUsers?.isEmpty ?? true {
                Logger.error("Input data", "No users can work in workplace \(workplace.name ?? "unknown")")
            }
            var days: [ScheduleDay] = []
            for dayNumber in 1..<(daysInMonth+1) {
                var availableUsers: [ScheduleUser] = []
                workplace.allowedUsers?.forEach { workplaceUser in
                    if let user = (dto.users?.filter { $0.id == workplaceUser.id })?.first {
                        if user.wantedDays?.contains(dayNumber) ?? false {
                            let user = ScheduleUser(id: user.id ?? 0, name: user.name ?? "unknown", workplacePriority: workplaceUser.priority ?? 0, assignmantLevel: .wantedDay, otherWorkplaceIDs: user.allowedWorkplaceIDs?.filter{ $0 != workplace.id ?? 0 } ?? [])
                            availableUsers.append(user)
                        }
                        if user.possibleDays?.contains(dayNumber) ?? false {
                            let user = ScheduleUser(id: user.id ?? 0, name: user.name ?? "unknown", workplacePriority: workplaceUser.priority ?? 0, assignmantLevel: .possibleDay, otherWorkplaceIDs: user.allowedWorkplaceIDs?.filter{ $0 != workplace.id ?? 0 } ?? [])
                            availableUsers.append(user)
                        }
                    }
                }
                if !availableUsers.isEmpty {
                    days.append(ScheduleDay(dayNumber: dayNumber, availableUsers: availableUsers))
                }
            }
            let scheduledWorkplace = ScheduleWorkplace(id: workplace.id ?? 0, name: workplace.name ?? "unknown", scheduleDays: days)
            workplaces.append(scheduledWorkplace)
        }
        
        let users: [User] = dto.users?.map { user in
            let workingDayLimitations: [UserWorkLimitation] = user.wishes?.filter { $0.type == .and }
                .compactMap { UserWorkLimitation(from: $0) } ?? []
            
            
            let workindDayXorLimitations: [UserWorkXorLimitation] = user.wishes?.filter { $0.type == .or }
                .map { wishDto in
                    let rules: [UserWorkLimitation] = wishDto.rules?.compactMap { UserWorkLimitation(from: $0) } ?? []
                return UserWorkXorLimitation(rules: rules)
            } ?? []
        
            let wishes = UserWishes(workingDayLimitations: workingDayLimitations, workindDayXorLimitations: workindDayXorLimitations)
            return User(id: user.id ?? 0, name: user.name ?? "unknown", wantedDayNumbers: user.wantedDays ?? [], possibleDayNumbers: user.possibleDays ?? [], workPlaceIDs: user.allowedWorkplaceIDs ?? [], wishes: wishes, maxWorkingDays: user.maxWorkingDays ?? 0)
            
            } ?? []
        let score = ScoreModel()
        let scheduleModel = ScheduleModel(versionNumber: 1, workplaces: workplaces, users: users, score: score)
        return scheduleModel
    }
    
    static func makeOutputDto(from model: ScheduleModel) -> OutputDto {
        let outputDto = OutputDto()
        outputDto.schedules = []
        
        model.workplaces.forEach { workplace in
            let schedule = ScheduleDto()
            schedule.workPlaceID = workplace.id
            schedule.workPlaceName = workplace.name
            schedule.scheduledDays = []
            
            workplace.scheduleDays.forEach { scheduleDay in
                if let selectedUser = scheduleDay.selectedUser {
                    let plannedDay = ScheduledDayDto()
                    plannedDay.dayNumber = scheduleDay.dayNumber
                    plannedDay.userID = selectedUser.id
                    schedule.scheduledDays?.append(plannedDay)
                }
            }
            outputDto.schedules?.append(schedule)
        }
            
        return outputDto
            
        
    }
    
    static func makeSnapshot(from model: ScheduleModel) -> ScheduleModelSnapshot {
        
        let users: [UserSnapshot] = model.users.map { user in
            let customDayLimits: [UserWorkLimitationSnapshot] = user.wishes.workingDayLimitations.map { UserWorkLimitationSnapshot(dayLimit: $0.dayLimit, dayNumbers: $0.dayNumbers) }
            let dayAlternatives: [UserWorkXorLimitationSnapshot] = user.wishes.workindDayXorLimitations.map { dayAlternative in
                let rules: [UserWorkLimitationSnapshot] = dayAlternative.rules.map {
                    UserWorkLimitationSnapshot(dayLimit: $0.dayLimit, dayNumbers: $0.dayNumbers)
                }
                return UserWorkXorLimitationSnapshot(rules: rules)
            }
            let wishes = UserWishesSnapshot(workingDayLimitations: customDayLimits, workindDayXorLimitations: dayAlternatives)
            return UserSnapshot(id: user.id, name: user.name, wantedDayNumbers: user.wantedDayNumbers, possibleDayNumbers: user.possibleDayNumbers, workPlaceIDs: user.workPlaceIDs, wishes: wishes, maxWorkingDays: user.maxWorkingDays)
        }
        let workplaces: [ScheduleWorkplaceSnapshot] = model.workplaces.map { workplace in
            let days: [ScheduleDaySnapshot] = workplace.scheduleDays.map { scheduleDay in
                var selectedUser: ScheduleUserSnapshot? = nil
                if let su = scheduleDay.selectedUser {
                    selectedUser = ScheduleUserSnapshot(id: su.id, name: su.name, workplacePriority: su.workplacePriority, assignmantLevel: su.assignmantLevel, otherWorkplaceIDs: su.otherWorkplaceIDs)
                }
                let availableUsers: [ScheduleUserSnapshot] = scheduleDay.availableUsers.map { su in
                    return ScheduleUserSnapshot(id: su.id, name: su.name, workplacePriority: su.workplacePriority, assignmantLevel: su.assignmantLevel, otherWorkplaceIDs: su.otherWorkplaceIDs)
                    
                }
                return ScheduleDaySnapshot(dayNumber: scheduleDay.dayNumber, selectedUser: selectedUser, availableUsers: availableUsers)
            }
            return ScheduleWorkplaceSnapshot(id: workplace.id, name: workplace.name, scheduleDays: days)
        }
        let score = ScoreModelSnapshot(scheduledDays: model.score.scheduledDays, preferredDays: model.score.preferredDays)
        return ScheduleModelSnapshot(versionNumber: model.versionNumber, daysLeftToPlan: model.daysLeftToPlan, users: users, workplaces: workplaces, score: score)
    }
    
    static func makeModel(versionNumber: Int, from snapshot: ScheduleModelSnapshot) -> ScheduleModel {
        let workplaces: [ScheduleWorkplace] = snapshot.workplaces.map { workplace in
            let scheduleDays: [ScheduleDay] = workplace.scheduleDays.map { scheduleDay in
                let selectedUser: ScheduleUser? = ScheduleUser(from: scheduleDay.selectedUser)
                let availableUsers: [ScheduleUser] = scheduleDay.availableUsers.compactMap { ScheduleUser(from: $0) }
                return ScheduleDay(dayNumber: scheduleDay.dayNumber, availableUsers: availableUsers, selectedUser: selectedUser)
            }
            return ScheduleWorkplace(id: workplace.id, name: workplace.name, scheduleDays: scheduleDays)
        }
        let users: [User] = snapshot.users.map { u in
            let workingDayLimitations: [UserWorkLimitation] = u.wishes.workingDayLimitations.map { UserWorkLimitation(from: $0) }
            let workindDayXorLimitations: [UserWorkXorLimitation] = u.wishes.workindDayXorLimitations.map { dayAlternative in
                let rules: [UserWorkLimitation] = dayAlternative.rules.compactMap { UserWorkLimitation(from: $0) }
                return UserWorkXorLimitation(rules: rules)
            }
            let wishes = UserWishes(workingDayLimitations: workingDayLimitations, workindDayXorLimitations: workindDayXorLimitations)
            return User(id: u.id, name: u.name, wantedDayNumbers: u.wantedDayNumbers, possibleDayNumbers: u.possibleDayNumbers, workPlaceIDs: u.workPlaceIDs, wishes: wishes, maxWorkingDays: u.maxWorkingDays)
        }
        let score = ScoreModel(from: snapshot.score)
        return ScheduleModel(versionNumber: versionNumber, workplaces: workplaces, users: users, score: score)
    }
    
    static func copy(model: ScheduleModel, withVersionNumber versionNumber: Int) -> ScheduleModel {
        return ModelBuilder.makeModel(versionNumber: versionNumber, from: ModelBuilder.makeSnapshot(from: model))
    }
}
