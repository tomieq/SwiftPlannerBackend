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
    
    private var bestScoreHits = 0
    
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
        
        self.possibleModels = []
        Logger.info("Finished", "Worker finished with planned \(self.bestModel.score.scheduledDays) days")
    }
    
    private func isSchedulingFinished() -> Bool {
        if self.bestModel.score.scheduledDays == self.maxPlannedDays {
            Logger.debug("Termination", "Reached max planned days (\(self.maxPlannedDays))")
            return true
        }

        if self.bestScoreHits > 400 {
            Logger.debug("Termination", "Reached limit of top score hits")
            return true
        }
        return false
    }
    
    private func startPlanningWithAssumtions() {
        self.makePossibleModels()
        
        if self.isSchedulingFinished() {
            return
        }
        
        while let nextModel = self.possibleModels.last {
            self.model = nextModel
            Logger.debug("Exercising new model", "Assigned model ver.\(self.model.versionNumber)")
            self.runSimpleAssignAlgorithmsUntilNoProgress()
            self.assignModelIfTheBest(model: self.model)
            
            if self.isSchedulingFinished() {
                return
            }
            if self.model.daysLeftToPlan > 0 {
                self.makePossibleModels()
                
                if self.isSchedulingFinished() {
                    return
                }
            }
            self.possibleModels.remove(object: self.model)
        }
        
    }
    
    private func assignModelIfTheBest(model: ScheduleModel) {
        
        // in future respect scoring metrics
        if model.score.scheduledDays > self.bestModel.score.scheduledDays {
            self.bestModel = model
            self.bestScoreHits = 0
        } else if self.model.score.scheduledDays == self.bestModel.score.scheduledDays {
            self.bestScoreHits = self.bestScoreHits + 1
        }
    }
    
    private func runSimpleAssignAlgorithmsUntilNoProgress() {
        
        while self.model.daysLeftToPlan > 0 {
            let plannedDaysBefore = model.score.scheduledDays
            Logger.debug("", "...starting all algorithms")
            self.runSimpleAssignAlgorithms()
            let plannedDaysAfter = model.score.scheduledDays
            if plannedDaysBefore == plannedDaysAfter { break }
        }
    }
    
    private func runSimpleAssignAlgorithms() {

        while self.model.daysLeftToPlan > 0 {
            let plannedDaysBefore = model.score.scheduledDays
            Logger.debug("", "......starting assignSingleCandidates()")
            self.assignSingleCandidates()
            let plannedDaysAfter = model.score.scheduledDays
            if plannedDaysBefore == plannedDaysAfter { break }
        }
        while self.model.daysLeftToPlan > 0 {
            let plannedDaysBefore = model.score.scheduledDays
            Logger.debug("", "......starting assignCandidateThatCanWorkOnlyHere()")
            self.assignCandidateThatCanWorkOnlyHere()
            let plannedDaysAfter = model.score.scheduledDays
            if plannedDaysBefore == plannedDaysAfter { break }
        }
    }
    
    // funkcja szuka kandydatów, którzy jako jedyni zgłosili się do pracy danego dnia w tym miejscu pracy i mogą pracować tylko
    // i wyłącznie w tym miejscu pracy
    // i dzień nie uczestniczy w życzeniach or(alternatywnych)
    private func assignSingleCandidates() {
        for workplace in self.model.workplaces {
            for scheduleDay in workplace.scheduleDays {
                if !scheduleDay.isScheduled, scheduleDay.availableUsers.count == 1,
                    let selectedUser = scheduleDay.availableUsers.first, selectedUser.otherWorkplaceIDs.isEmpty,
                    !(self.model.findUser(for: selectedUser)?.wishes.xorLimitationContains(dayNumber: scheduleDay.dayNumber) ?? false) {
                    do {
                        try self.model.assign(user: selectedUser, on: scheduleDay.dayNumber, to: workplace)
                    } catch {
                        // some serious problem here
                    }
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
                if !scheduleDay.isScheduled, !scheduleDay.availableUsers.isEmpty {
                    let usersThatCanWorkOnlyHere = scheduleDay.availableUsers.filter { $0.otherWorkplaceIDs.isEmpty }
                    let usersThatWantWork = usersThatCanWorkOnlyHere.filter{ $0.assignmantLevel == .wantedDay }
                    if usersThatWantWork.count == 1, let selectedUser = usersThatCanWorkOnlyHere.first {
                        do {
                            try self.model.assign(user: selectedUser, on: scheduleDay.dayNumber, to: workplace)
                        } catch {
                            // some serious problem here
                        }
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
                        do {
                            try possibleModel.assign(user: user, on: scheduleDay.dayNumber, to: workplace)
                            self.assignModelIfTheBest(model: possibleModel)
                            if possibleModel.daysLeftToPlan > 0 {
                                self.possibleModels.append(possibleModel)
                            }
                        } catch {
                            // some serious problem here
                        }
                        Logger.debug("ModelPreparation", "END model ver.\(possibleModel.versionNumber)")
                        
                        
                    }
                }
            }
        }
    }
}
