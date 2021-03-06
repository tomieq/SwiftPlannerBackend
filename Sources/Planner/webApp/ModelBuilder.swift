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
        
        let workplaces: [ScheduleWorkplaceSnapshot] = model.workplaces.map { ScheduleWorkplaceSnapshot(from: $0) }
        let users: [UserSnapshot] = model.users.map { UserSnapshot(from: $0) }
        let score = ScoreModelSnapshot(from: model.score)
        return ScheduleModelSnapshot(versionNumber: model.versionNumber, daysLeftToPlan: model.daysLeftToPlan, users: users, workplaces: workplaces, score: score)
    }
    
    static func makeModel(versionNumber: Int, from snapshot: ScheduleModelSnapshot) -> ScheduleModel {
        let workplaces: [ScheduleWorkplace] = snapshot.workplaces.map { ScheduleWorkplace(from: $0) }
        let users: [User] = snapshot.users.map { User(from: $0) }
        let score = ScoreModel(from: snapshot.score)
        return ScheduleModel(versionNumber: versionNumber, workplaces: workplaces, users: users, score: score)
    }
    
    static func copy(model: ScheduleModel, withVersionNumber versionNumber: Int) -> ScheduleModel {
        return ModelBuilder.makeModel(versionNumber: versionNumber, from: ModelBuilder.makeSnapshot(from: model))
    }
}
