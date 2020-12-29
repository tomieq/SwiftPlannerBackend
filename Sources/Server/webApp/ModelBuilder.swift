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
                .compactMap { wishDto in
                    guard let dayNumbers = wishDto.days, let amount = wishDto.amount else {
                        Logger.warning("Input data", "Wish `and` for user \(user.name ?? "unknown") is corrupted")
                        return nil
                    }
                    return UserWorkLimitation(dayLimit: amount, dayNumbers: dayNumbers)
                } ?? []
            
            
            let workindDayXorLimitations: [UserWorkXorLimitation] = user.wishes?.filter { $0.type == .or }
                .map { wishDto in
                    let rules: [UserWorkLimitation] = wishDto.rules?.compactMap { rule in
                        guard let dayNumbers = rule.days, let amount = rule.amount else {
                            Logger.warning("Input data", "Wish `or` for user \(user.name ?? "unknown") is corrupted")
                            return nil
                        }
                        return UserWorkLimitation(dayLimit: amount, dayNumbers: dayNumbers)
                    } ?? []
                return UserWorkXorLimitation(rules: rules)
            } ?? []
        
            let wishes = UserWishes(workingDayLimitations: workingDayLimitations, workindDayXorLimitations: workindDayXorLimitations)
            return User(id: user.id ?? 0, name: user.name ?? "unknown", wantedDayNumbers: user.wantedDays ?? [], possibleDayNumbers: user.possibleDays ?? [], workPlaceIDs: user.allowedWorkplaceIDs ?? [], wishes: wishes, maxWorkingDays: user.maxWorkingDays ?? 0)
            
            } ?? []
        let scheduleModel = ScheduleModel(versionNumber: 1, workplaces: workplaces, users: users)
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
        return ScheduleModelSnapshot(versionNumber: model.versionNumber, scheduledDaysAmount: model.scheduledDaysAmount, daysLeftToPlan: model.daysLeftToPlan, users: users, workplaces: workplaces)
    }
    
    static func makeModel(versionNumber: Int, from snapshot: ScheduleModelSnapshot) -> ScheduleModel {
        let workplaces: [ScheduleWorkplace] = snapshot.workplaces.map { workplace in
            let scheduleDays: [ScheduleDay] = workplace.scheduleDays.map { scheduleDay in
                var selectedUser: ScheduleUser? = nil
                if let u = scheduleDay.selectedUser {
                    selectedUser = ScheduleUser(id: u.id, name: u.name, workplacePriority: u.workplacePriority, assignmantLevel: u.assignmantLevel, otherWorkplaceIDs: u.otherWorkplaceIDs)
                }
                let availableUsers: [ScheduleUser] = scheduleDay.availableUsers.map { u in
                    return ScheduleUser(id: u.id, name: u.name, workplacePriority: u.workplacePriority, assignmantLevel: u.assignmantLevel, otherWorkplaceIDs: u.otherWorkplaceIDs)
                }
                return ScheduleDay(dayNumber: scheduleDay.dayNumber, availableUsers: availableUsers, selectedUser: selectedUser)
            }
            return ScheduleWorkplace(id: workplace.id, name: workplace.name, scheduleDays: scheduleDays)
        }
        let users: [User] = snapshot.users.map { u in
            let workingDayLimitations: [UserWorkLimitation] = u.wishes.workingDayLimitations.map { UserWorkLimitation(dayLimit: $0.dayLimit, dayNumbers: $0.dayNumbers) }
            let workindDayXorLimitations: [UserWorkXorLimitation] = u.wishes.workindDayXorLimitations.map { dayAlternative in
                let rules: [UserWorkLimitation] = dayAlternative.rules.map { UserWorkLimitation(dayLimit: $0.dayLimit, dayNumbers: $0.dayNumbers) }
                return UserWorkXorLimitation(rules: rules)
            }
            let wishes = UserWishes(workingDayLimitations: workingDayLimitations, workindDayXorLimitations: workindDayXorLimitations)
            return User(id: u.id, name: u.name, wantedDayNumbers: u.wantedDayNumbers, possibleDayNumbers: u.possibleDayNumbers, workPlaceIDs: u.workPlaceIDs, wishes: wishes, maxWorkingDays: u.maxWorkingDays)
        }
        return ScheduleModel(versionNumber: versionNumber, workplaces: workplaces, users: users)
    }
    
    static func copy(model: ScheduleModel, withVersionNumber versionNumber: Int) -> ScheduleModel {
        return ModelBuilder.makeModel(versionNumber: versionNumber, from: ModelBuilder.makeSnapshot(from: model))
    }
}
