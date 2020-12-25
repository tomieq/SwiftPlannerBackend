//
//  ModelBuilder.swift
//  
//
//  Created by Tomasz Kucharski on 25/12/2020.
//

import Foundation

class ModelBuilder {
    static func buildModel(dto: InputDto) -> ScheduleModel? {
        
        guard let daysInMonth = dto.daysInMonth else {
            print("Error! Missing daysInMonth value.")
            return nil
        }
        
        var workplaces: [ScheduleWorkplace] = []
        dto.workplaces?.forEach { workplace in
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
                days.append(ScheduleDay(dayNumber: dayNumber, availableUsers: availableUsers))
            }
            let scheduledWorkplace = ScheduleWorkplace(id: workplace.id ?? 0, name: workplace.name ?? "unknown", scheduleDays: days)
            workplaces.append(scheduledWorkplace)
        }
        
        let users: [User] = dto.users?.map{ User(id: $0.id ?? 0, name: $0.name ?? "unknown", wantedDayNumbers: $0.wantedDays ?? [], possibleDayNumbers: $0.possibleDays ?? [], workPlaceIDs: $0.allowedWorkplaceIDs ?? [], maxWorkingDays: $0.maxWorkingDays ?? 0) } ?? []
        let scheduleModel = ScheduleModel(workplaces: workplaces, users: users)
        return scheduleModel
    }
    
    static func buildOutputDto(model: ScheduleModel) -> OutputDto {
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
}
