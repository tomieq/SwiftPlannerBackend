//
//  ScheduleEngine.swift
//  
//
//  Created by Tomasz Kucharski on 25/12/2020.
//

import Foundation

class ScheduleEngine {
    private let model: ScheduleModel
    private let maximumDaysToPlan: Int
    
    init(model: ScheduleModel) {
        self.model = model
        
        // calculate max algorith possibilities
        var maxPlannedDays = 0
        var allDays = 0
        self.model.workplaces.forEach { workplace in
            workplace.scheduleDays.forEach { scheduleDay in
                allDays = allDays + 1
                if !scheduleDay.availableUsers.isEmpty {
                    maxPlannedDays = maxPlannedDays + 1
                }
            }
        }
        self.maximumDaysToPlan = maxPlannedDays
        if maxPlannedDays != allDays {
            print("Warning! Only \(maxPlannedDays) days of \(allDays) have candidates for work!")
        }
    }
    
    func exec() {
        model.workplaces.forEach { workplace in
            workplace.scheduleDays.forEach { scheduleDay in
                if scheduleDay.availableUsers.count == 1, let selectedUser = scheduleDay.availableUsers.first, selectedUser.otherWorkplaceIDs.isEmpty {
                    model.assign(user: selectedUser, on: scheduleDay.dayNumber, to: workplace)
                }
            }
        }
    }
}
