//
//  ScheduleModel.swift
//  
//
//  Created by Tomasz Kucharski on 25/12/2020.
//

import Foundation

class ScheduleModel: Codable {
    
    let versionNumber: Int
    var scheduledDaysAmount: Int = 0
    var daysLeftToPlan: Int = 0
    var users: [User]
    let workplaces: [ScheduleWorkplace]
    let score: ScoreModel
    
    init(versionNumber: Int, workplaces: [ScheduleWorkplace], users: [User], score: ScoreModel) {
        self.versionNumber = versionNumber
        self.workplaces = workplaces
        self.users = users
        self.score = score
        self.updateModelStats()
    }
    
    private func updateModelStats() {
        if self.users.isEmpty {
            self.daysLeftToPlan = 0
        } else {
           var maxToPlan = 0
           for workplace in self.workplaces {
               for scheduleDay in workplace.scheduleDays {
                   if !scheduleDay.availableUsers.isEmpty {
                       maxToPlan = maxToPlan + 1
                   }
               }
           }
           self.daysLeftToPlan = maxToPlan
        }
        var scheduledDaysAmount = 0
        for workplace in self.workplaces {
            for scheduleDay in workplace.scheduleDays {
                if scheduleDay.isScheduled {
                    scheduledDaysAmount = scheduledDaysAmount + 1
                }
            }
        }
        self.scheduledDaysAmount = scheduledDaysAmount
    }
    
    private func updateOtherUserPossibilitiesAfterAssignment(on dayNumber: Int, in workplace: ScheduleWorkplace) {
        // mark users with possibilities on the same day that they don't have to work in this place any more
        for workplaceItem in self.workplaces {
            workplaceItem.scheduleDays.filter { $0.dayNumber == dayNumber }.first?
                .availableUsers.forEach { availableUser in
                availableUser.otherWorkplaceIDs = availableUser.otherWorkplaceIDs.filter { $0 != workplace.id }
            }
        }
    }
    
    func assign(user: ScheduleUser, on dayNumber: Int, to workplace: ScheduleWorkplace) throws {
        if let userInModel = (self.users.filter { $0.id == user.id }.first) {
            
            // assign that user to selected workplace in particular day
            do {
                try self.workplaces.filter { $0.id == workplace.id }
                .first?.scheduleDays
                .filter { $0.dayNumber == dayNumber }
                .first?.assign(user: user)
                Logger.info("Assigment" ,"Assigned \(user.name) to work on \(dayNumber.ordinal) in \(workplace.name).")
            } catch {
                Logger.error("AssigmentError", error.localizedDescription)
                throw error
            }
            userInModel.maxWorkingDays = userInModel.maxWorkingDays - 1
            if userInModel.maxWorkingDays == 0 {
                Logger.info("Exclusion" ,"User \(user.name) has reached his limit of working days.")
                self.remove(user: user)
                self.updateOtherUserPossibilitiesAfterAssignment(on: dayNumber, in: workplace)
                self.updateModelStats()
                return
            }
            

            // remove user's possible days from previous, current and day after day [workplace tree]
            let daysToClean = [dayNumber - 1, dayNumber, dayNumber + 1]
            for dayToClean in daysToClean {
                self.markUserCanNotWorkOn(dayNumber: dayToClean, user: userInModel)
            }
            
            // check if user can be assigned on any other day
            var numberOfPossibleDays = 0
            for workplace in self.workplaces {
                for scheduleDay in workplace.scheduleDays {
                    numberOfPossibleDays = numberOfPossibleDays + scheduleDay.availableUsers.count { $0.id == user.id }
                }
            }
            if numberOfPossibleDays == 0 {
                Logger.info("Exclusion" ,"User \(user.name) has no more possible days to work.")
                self.remove(user: user)
                self.updateOtherUserPossibilitiesAfterAssignment(on: dayNumber, in: workplace)
                self.updateModelStats()
                return
            }
            
            
            // check if assigned day is in user's wish limitations
            for limitation in userInModel.wishes.workingDayLimitations {
                if limitation.dayNumbers.contains(dayNumber) {
                    limitation.dayLimit = limitation.dayLimit - 1
                    limitation.dayNumbers = limitation.dayNumbers.filter { $0 != dayNumber }
                    
                    // jeśli limit został wyczerpany, usuń użytkownika z list availableUsers
                    if limitation.dayLimit == 0 {
                        for dayToRemove in limitation.dayNumbers {
                            self.markUserCanNotWorkOn(dayNumber: dayToRemove, user: userInModel)
                        }
                        limitation.dayNumbers = []
                    }
                }
            }
            // check if assigned day is in user's wish alternatives
            for xorLimitation in userInModel.wishes.workindDayXorLimitations {
                if xorLimitation.contains(dayNumber: dayNumber) {
                    for rule in xorLimitation.rules {
                        if rule.dayNumbers.contains(dayNumber) {

                            rule.dayLimit = rule.dayLimit - 1
                            rule.dayNumbers = rule.dayNumbers.filter { $0 != dayNumber }
                            
                            if rule.dayLimit == 0 {
                                for dayToRemove in rule.dayNumbers {
                                    self.markUserCanNotWorkOn(dayNumber: dayToRemove, user: userInModel)
                                }
                                rule.dayNumbers = []
                            }
                            
                        } else {
                            for dayToRemove in rule.dayNumbers {
                                self.markUserCanNotWorkOn(dayNumber: dayToRemove, user: userInModel)
                            }
                            rule.dayNumbers = []
                        }
                    }
                    xorLimitation.rules = xorLimitation.rules.filter { $0.dayNumbers.count > 0 }
                }
            }
            self.updateOtherUserPossibilitiesAfterAssignment(on: dayNumber, in: workplace)
            self.updateModelStats()
            
            
            Logger.debug("Stats", "Planned \(self.scheduledDaysAmount) days and \(self.daysLeftToPlan) days still can be planned")
            
            //print("ScheduleModel = \(self.debugDescription)")
        } else {
            Logger.error("Code error", "User \(user.name) not found in users list.")
        }
    }
    
    func remove(user: User) {
        self.remove(userID: user.id)
    }
    
    func remove(user: ScheduleUser) {
        self.remove(userID: user.id)
    }
    
    private func remove(userID: Int) {
        // remove user from user tree
        self.users = self.users.filter { $0.id != userID }
        // update workplace tree to remove user from availableUsers
        for workplace in self.workplaces {
            for scheduleDay in workplace.scheduleDays {
                scheduleDay.availableUsers = scheduleDay.availableUsers.filter { $0.id != userID }
            }
        }
    }
    
    private func markUserCanNotWorkOn(dayNumber: Int, user: User) {

        for workplace in self.workplaces {
            workplace.scheduleDays.filter{ dayNumber == $0.dayNumber }.forEach { scheduleDay in
                scheduleDay.availableUsers = scheduleDay.availableUsers.filter { $0.id != user.id }
            }
        }
        user.wantedDayNumbers = user.wantedDayNumbers.filter { dayNumber != $0 }
        user.possibleDayNumbers = user.possibleDayNumbers.filter { dayNumber != $0 }

    }
    
    
    func findUser(for user: ScheduleUser) -> User? {
        return self.users.filter { $0.id == user.id }.first
    }
}

extension ScheduleModel: CustomDebugStringConvertible {
    var debugDescription: String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        if let jsonData = try? jsonEncoder.encode(self) {
            return String(decoding: jsonData, as: UTF8.self)
        }
        return "nil"
    }
}

extension ScheduleModel: Equatable {
    static func == (lhs: ScheduleModel, rhs: ScheduleModel) -> Bool {
        return lhs.versionNumber == rhs.versionNumber
    }
}
