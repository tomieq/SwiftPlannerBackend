//
//  ScheduleEngine.swift
//  
//
//  Created by Tomasz Kucharski on 25/12/2020.
//

import Foundation

class ScheduleEngine {
    private var model: ScheduleModel {
        didSet {
            Logger.debug("New model", "Assigned model ver.\(self.model.versionNumber)")
        }
    }
    public var bestModel: ScheduleModel
    private var possibleModels: [ScheduleModel]
    private var possibleModelCounter = 1
    
    private let maxPlannedDays: Int
    
    init(model: ScheduleModel) {
        

        model.users.forEach { user in
            if user.maxWorkingDays == 0 {
                Logger.warning("inputDataProblem", "User \(user.name) was excluded because he has maxWorkingDays set to 0.")
                model.remove(user: user)
            }
        }
        
        self.model = model
        self.maxPlannedDays = model.daysLeftToPlan
        self.bestModel = model
        self.possibleModels = []
        
        //Logger.debug("Model", self.model.debugDescription)
        Logger.info("", "Scheduler will be able to plan \(self.maxPlannedDays) days (based on lists of wanted and possible days).")
    }
    
    func exec() {

        self.runSimpleAssignAlgorithmsUntilNoProgress()
        
        if model.daysLeftToPlan == 0 {
            Logger.info("", "Success! Scheduler planned all possible days.")
            self.bestModel = self.model
        } else {
            self.startPlanningWithAssumtions()
        }
        
        Logger.info("Finished", "Worked finished with planned \(self.model.plannedDays) days")
    }
    
    private func startPlanningWithAssumtions() {
        self.makePossibleModels()
        
        while let nextModel = self.possibleModels.last {
            self.model = nextModel
            Logger.debug("=== New model", "Assigned model ver.\(self.model.versionNumber)")
            self.runSimpleAssignAlgorithmsUntilNoProgress()
            self.assignModelIfTheBest(model: self.model)
            
            // jeśli zaplanowano wszystko, zakończ
            if self.model.plannedDays == self.maxPlannedDays {
                return
            }
            if self.model.daysLeftToPlan > 0 {
                self.makePossibleModels()
                
                if self.bestModel.plannedDays == self.maxPlannedDays {
                    return
                }
            }
            self.possibleModels.remove(object: self.model)
        }
        
    }
    
    private func assignModelIfTheBest(model: ScheduleModel) {
        
        // in future respect scoring metrics
        if model.plannedDays > self.bestModel.plannedDays {
            self.bestModel = model
        }
    }
    
    private func runSimpleAssignAlgorithmsUntilNoProgress() {
        
        while self.model.daysLeftToPlan > 0 {
            let plannedDaysBefore = model.plannedDays
            Logger.debug("", "...starting all algorithms")
            self.runSimpleAssignAlgorithms()
            let plannedDaysAfter = model.plannedDays
            if plannedDaysBefore == plannedDaysAfter { break }
        }
    }
    
    private func runSimpleAssignAlgorithms() {

        while self.model.daysLeftToPlan > 0 {
            let plannedDaysBefore = model.plannedDays
            Logger.debug("", "......starting assignSingleCandidates()")
            self.assignSingleCandidates()
            let plannedDaysAfter = model.plannedDays
            if plannedDaysBefore == plannedDaysAfter { break }
        }
        while self.model.daysLeftToPlan > 0 {
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
                if scheduleDay.selectedUser == nil, scheduleDay.availableUsers.count == 1, let selectedUser = scheduleDay.availableUsers.first, selectedUser.otherWorkplaceIDs.isEmpty {
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
                if scheduleDay.selectedUser == nil, !scheduleDay.availableUsers.isEmpty {
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

    
    func makePossibleModels() {
        
        for workplace in self.model.workplaces {
            for scheduleDay in workplace.scheduleDays {
                if scheduleDay.selectedUser == nil, !scheduleDay.availableUsers.isEmpty {
                    
                    let wantingUsers = scheduleDay.availableUsers.filter { $0.assignmantLevel == .wantedDay }
                    let users = wantingUsers.isEmpty ? scheduleDay.availableUsers : wantingUsers
                    for user in users {
                        self.possibleModelCounter = self.possibleModelCounter + 1
                        let possibleModel = ModelBuilder.copy(model: self.model, withVersionNumber: self.possibleModelCounter)

                        Logger.debug("ModelPreparation", "START model ver.\(possibleModel.versionNumber)")
                        possibleModel.assign(user: user, on: scheduleDay.dayNumber, to: workplace)
                        Logger.debug("ModelPreparation", "END model ver.\(possibleModel.versionNumber)")
                        
                        self.assignModelIfTheBest(model: possibleModel)
                        if possibleModel.daysLeftToPlan > 0 {
                            self.possibleModels.append(possibleModel)
                        }
                    }
                }
            }
        }
    }
}
