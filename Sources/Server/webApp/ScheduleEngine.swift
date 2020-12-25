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
        

        model.users.forEach { user in
            if user.maxWorkingDays == 0 {
                print("Warning! User \(user.name) was excluded because he has maxWorkingDays set to 0.")
                model.remove(user: user)
            }
        }

        self.model = model
        
        
        //print("model \(self.model.debugDescription)")
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
        self.tryAssignSingleCandidates()
    }
    
    // funkcja szuka kandydatów, którzy jako jedyni zgłosili się do pracy danego dnia w tym miejscu pracy i mogą pracować tylko
    // i wyłącznie w tym miejscu pracy
    private func tryAssignSingleCandidates() {
        model.workplaces.forEach { workplace in
            workplace.scheduleDays.forEach { scheduleDay in
                if scheduleDay.availableUsers.count == 1, let selectedUser = scheduleDay.availableUsers.first, selectedUser.otherWorkplaceIDs.isEmpty {
                    let maxWorkingDays = model.assign(user: selectedUser, on: scheduleDay.dayNumber, to: workplace)
                    if maxWorkingDays == 0 {
                        model.remove(user: selectedUser)
                    }
                }
            }
        }
    }
}
