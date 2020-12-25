//
//  ScheduleEngine.swift
//  
//
//  Created by Tomasz Kucharski on 25/12/2020.
//

import Foundation

class ScheduleEngine {
    private let model: ScheduleModel
    
    init(model: ScheduleModel) {
        

        model.users.forEach { user in
            if user.maxWorkingDays == 0 {
                print("Warning! User \(user.name) was excluded because he has maxWorkingDays set to 0.")
                model.remove(user: user)
            }
        }

        self.model = model
        
        
        //print("model \(self.model.debugDescription)")
        
        print("Scheduler will be able to plan \(model.maxDaysToPlan) days.")
    }
    
    func exec() {
        
        while model.plannedDays != model.maxDaysToPlan {
            let plannedDaysBefore = model.plannedDays
            self.runAlgorithms()
            let plannedDaysAfter = model.plannedDays
            if plannedDaysBefore == plannedDaysAfter { break }
        }
        
        if model.plannedDays == model.maxDaysToPlan {
            print("Success! Scheduler planned all possible days.")
        }
    }
    
    private func runAlgorithms() {

        while model.plannedDays != model.maxDaysToPlan {
            let plannedDaysBefore = model.plannedDays
            self.assignSingleCandidates()
            let plannedDaysAfter = model.plannedDays
            if plannedDaysBefore == plannedDaysAfter { break }
        }
        while model.plannedDays != model.maxDaysToPlan {
            let plannedDaysBefore = model.plannedDays
            self.assignCandidateThatCanWorkOnlyHere()
            let plannedDaysAfter = model.plannedDays
            if plannedDaysBefore == plannedDaysAfter { break }
        }
        print("plannedDaysAfter = \(model.plannedDays)")
    }
    
    // funkcja szuka kandydatów, którzy jako jedyni zgłosili się do pracy danego dnia w tym miejscu pracy i mogą pracować tylko
    // i wyłącznie w tym miejscu pracy
    private func assignSingleCandidates() {
        for workplace in self.model.workplaces {
            for scheduleDay in workplace.scheduleDays {
                if scheduleDay.availableUsers.count == 1, let selectedUser = scheduleDay.availableUsers.first, selectedUser.otherWorkplaceIDs.isEmpty {
                    self.model.assign(user: selectedUser, on: scheduleDay.dayNumber, to: workplace)
                    return
                }
            }
        }
    }
    
    // funkcja szuka kandydatów, którzy zgłosili się do pracy danego dnia i wybiera takiego, który jako jedyny tylko tutaj może pracować
    func assignCandidateThatCanWorkOnlyHere() {
        for workplace in self.model.workplaces {
            for scheduleDay in workplace.scheduleDays {
                
                let usersThatCanWorkOnlyHere = scheduleDay.availableUsers.filter { $0.otherWorkplaceIDs.isEmpty }
                if usersThatCanWorkOnlyHere.count == 1, let selectedUser = usersThatCanWorkOnlyHere.first {
                    self.model.assign(user: selectedUser, on: scheduleDay.dayNumber, to: workplace)
                    return
                }
            }
        }
    }
}
