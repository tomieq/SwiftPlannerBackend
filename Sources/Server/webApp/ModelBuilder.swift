//
//  ModelBuilder.swift
//  
//
//  Created by Tomasz Kucharski on 25/12/2020.
//

import Foundation

class ModelBuilder {
    static func buildModel(dto: InputDto) -> ScheduleModel {
        
        var workplaces: [ScheduleWorkplace] = []
        dto.workplaces?.forEach { workplace in
            var days: [ScheduleDay] = []
            for dayNumber in 1..<((dto.daysInMonth ?? 0)+1) {
                var availableUsers: [ScheduleUser] = []
                workplace.allowedUsers?.forEach { workplaceUser in
                    if let user = (dto.users?.filter { $0.id == workplaceUser.id })?.first {
                        if user.wantedDays?.contains(dayNumber) ?? false {
                            let user = ScheduleUser(id: user.id ?? 0, name: user.name ?? "unknown", workplacePriority: workplaceUser.priority ?? 0, assignmantLevel: .wantedDay)
                            availableUsers.append(user)
                        }
                        if user.possibleDays?.contains(dayNumber) ?? false {
                            let user = ScheduleUser(id: user.id ?? 0, name: user.name ?? "unknown", workplacePriority: workplaceUser.priority ?? 0, assignmantLevel: .possibleDay)
                            availableUsers.append(user)
                        }
                    }
                }
                days.append(ScheduleDay(dayNumber: dayNumber, selectedUser: nil, availableUsers: availableUsers))
            }
            let scheduledWorkplace = ScheduleWorkplace(id: workplace.id ?? 0, name: workplace.name ?? "unknown", days: days)
            workplaces.append(scheduledWorkplace)
        }

        let scheduleModel = ScheduleModel(workplaces: workplaces)
        return scheduleModel
    }
}
