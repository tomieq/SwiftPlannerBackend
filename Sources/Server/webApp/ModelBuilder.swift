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
            print("Error! Missing daysInMonth value.")
            return nil
        }
        
        var workplaces: [ScheduleWorkplace] = []
        dto.workplaces?.forEach { workplace in
            if workplace.allowedUsers?.isEmpty ?? true {
                print("Error! No users can work in workplace \(workplace.name ?? "unknown")")
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
        
        let users: [User] = dto.users?.map{ User(id: $0.id ?? 0, name: $0.name ?? "unknown", wantedDayNumbers: $0.wantedDays ?? [], possibleDayNumbers: $0.possibleDays ?? [], workPlaceIDs: $0.allowedWorkplaceIDs ?? [], maxWorkingDays: $0.maxWorkingDays ?? 0) } ?? []
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
        
        let users: [UserSnapshot] = model.users.map {
            UserSnapshot(id: $0.id, name: $0.name, wantedDayNumbers: $0.wantedDayNumbers, possibleDayNumbers: $0.possibleDayNumbers, workPlaceIDs: $0.workPlaceIDs, maxWorkingDays: $0.maxWorkingDays)
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
        return ScheduleModelSnapshot(versionNumber: model.versionNumber, plannedDays: model.plannedDays, daysLeftToPlan: model.daysLeftToPlan, users: users, workplaces: workplaces)
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
            return User(id: u.id, name: u.name, wantedDayNumbers: u.wantedDayNumbers, possibleDayNumbers: u.possibleDayNumbers, workPlaceIDs: u.workPlaceIDs, maxWorkingDays: u.maxWorkingDays)
        }
        return ScheduleModel(versionNumber: versionNumber, workplaces: workplaces, users: users)
    }
}
