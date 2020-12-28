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
                Logger.warning("inputDataProblem", "User \(user.name) was excluded because he has maxWorkingDays set to 0.")
                model.remove(user: user)
            }
        }

        self.model = model
        
        
        //print("model \(self.model.debugDescription)")
        
        Logger.info("", "Scheduler will be able to plan \(model.daysLeftToPlan) days (based on lists of wanted and possible days).")
    }
    
    func exec() {
        
        while model.daysLeftToPlan > 0 {
            let plannedDaysBefore = model.plannedDays
            Logger.debug("", "...starting all algorithms")
            self.runAlgorithms()
            let plannedDaysAfter = model.plannedDays
            if plannedDaysBefore == plannedDaysAfter { break }
        }
        
        if model.plannedDays == model.daysLeftToPlan {
            Logger.info("", "Success! Scheduler planned all possible days.")
        }
    }
    
    private func runAlgorithms() {

        while model.daysLeftToPlan > 0 {
            let plannedDaysBefore = model.plannedDays
            Logger.debug("", "......starting assignSingleCandidates()")
            self.assignSingleCandidates()
            let plannedDaysAfter = model.plannedDays
            if plannedDaysBefore == plannedDaysAfter { break }
        }
        while model.daysLeftToPlan > 0 {
            let plannedDaysBefore = model.plannedDays
            Logger.debug("", "......starting assignCandidateThatCanWorkOnlyHere()")
            self.assignCandidateThatCanWorkOnlyHere()
            let plannedDaysAfter = model.plannedDays
            if plannedDaysBefore == plannedDaysAfter { break }
        }
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
    
    // funkcja szuka kandydatów, którzy zgłosili się do pracy danego dnia i wybiera takiego, który jako jedyny tylko tutaj może pracować,
    // a dany dzień ma jako `wanted` (a nie `possible`)
    func assignCandidateThatCanWorkOnlyHere() {
        for workplace in self.model.workplaces {
            for scheduleDay in workplace.scheduleDays {
                
                let usersThatCanWorkOnlyHere = scheduleDay.availableUsers.filter { $0.otherWorkplaceIDs.isEmpty }
                let usersThatWantWork = usersThatCanWorkOnlyHere.filter{ $0.assignmantLevel == .wantedDay }
                if usersThatWantWork.count == 1, let selectedUser = usersThatCanWorkOnlyHere.first {
                    self.model.assign(user: selectedUser, on: scheduleDay.dayNumber, to: workplace)
                    return
                }
            }
        }
    }
}
