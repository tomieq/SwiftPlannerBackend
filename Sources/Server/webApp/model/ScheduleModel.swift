//
//  ScheduleModel.swift
//  
//
//  Created by Tomasz Kucharski on 25/12/2020.
//

import Foundation

class ScheduleModel: Codable {
    
    let workplaces: [ScheduleWorkplace]
    var users: [User]
    
    var plannedDays: Int = 0
    var daysLeftToPlan: Int = 0
    
    
    init(workplaces: [ScheduleWorkplace], users: [User]) {
        self.workplaces = workplaces
        self.users = users
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
        var planned = 0
        for workplace in self.workplaces {
            for scheduleDay in workplace.scheduleDays {
                if case .some = scheduleDay.selectedUser {
                    planned = planned + 1
                }
            }
        }
        self.plannedDays = planned
        print("Model stats: Planned \(self.plannedDays) days and \(self.daysLeftToPlan) days still can be planned")
    }
    
    func assign(user: ScheduleUser, on dayNumber: Int, to workplace: ScheduleWorkplace) {
        if let userInModel = (self.users.filter { $0.id == user.id }.first) {
            print("Assigned \(user.name) to work on \(dayNumber.ordinal) in \(workplace.name).")
            
            // assign that user to selected workplace in particular day
            self.workplaces.filter { $0.id == workplace.id }.first?.scheduleDays.filter { $0.dayNumber == dayNumber }.first?.selectedUser = user
            
            userInModel.maxWorkingDays = userInModel.maxWorkingDays - 1
            if userInModel.maxWorkingDays == 0 {
                print("Info: User \(user.name) has reached his limit of working days.")
                self.remove(user: user)
            } else {

                // remove that day from user's wanted and possible days [user's tree]
                userInModel.wantedDayNumbers = userInModel.wantedDayNumbers.filter { $0 != dayNumber }
                userInModel.possibleDayNumbers = userInModel.possibleDayNumbers.filter { $0 != dayNumber }
            }
            
            // remove user's possible days from previous, current and day after day [workplace tree]
            for workplace in self.workplaces {
                let daysToClean = [dayNumber - 1, dayNumber, dayNumber + 1]
                workplace.scheduleDays.filter{ daysToClean.contains($0.dayNumber) }.forEach { scheduleDay in
                    scheduleDay.availableUsers = scheduleDay.availableUsers.filter { $0.id != user.id }
                }
            }
            // check if there are any possible days left
            var numberOfPossibleDays = 0
            for workplace in self.workplaces {
                for scheduleDay in workplace.scheduleDays {
                    numberOfPossibleDays = numberOfPossibleDays + scheduleDay.availableUsers.count { $0.id == user.id }
                }
            }
            if numberOfPossibleDays == 0 {
                print("Info: User \(user.name) has no more possible days to work.")
                self.remove(user: user)
            }
            
            
            // mark users with possibilities on the same day that they don't have to work in this place any more
            for workplaceItem in self.workplaces {
                workplaceItem.scheduleDays.filter { $0.dayNumber == dayNumber }.first?.availableUsers.forEach { availableUser in
                    availableUser.otherWorkplaceIDs = availableUser.otherWorkplaceIDs.filter { $0 != workplace.id }
                }
            }
            self.updateModelStats()
            
            //print("ScheduleModel = \(self.debugDescription)")
        } else {
            print("Error! User \(user.name) not found in users list.")
        }
    }
    
    func remove(user: User) {
        self.remove(userID: user.id)
    }
    
    func remove(user: ScheduleUser) {
        self.remove(userID: user.id)
    }
    
    private func remove(userID: Int) {
        self.users = self.users.filter { $0.id != userID }
        for workplace in self.workplaces {
            for scheduleDay in workplace.scheduleDays {
                scheduleDay.availableUsers = scheduleDay.availableUsers.filter { $0.id != userID }
            }
        }
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

class ScheduleWorkplace: Codable {
    let id: Int
    let name: String
    let scheduleDays: [ScheduleDay]
    
    init(id: Int, name: String, scheduleDays: [ScheduleDay]) {
        self.id = id
        self.name = name
        self.scheduleDays = scheduleDays
    }
}

class ScheduleDay: Codable {
    let dayNumber: Int
    var selectedUser: ScheduleUser?
    var availableUsers: [ScheduleUser]
    
    init(dayNumber: Int, availableUsers: [ScheduleUser]) {
        self.dayNumber = dayNumber
        self.availableUsers = availableUsers
    }
}

class ScheduleUser: Codable {
    let id: Int
    let name: String
    let workplacePriority: Int
    let assignmantLevel: AssignmaneLevel
    var otherWorkplaceIDs: [Int]
    
    init(id: Int, name: String, workplacePriority: Int, assignmantLevel: AssignmaneLevel, otherWorkplaceIDs: [Int]) {
        self.id = id
        self.name = name
        self.workplacePriority = workplacePriority
        self.assignmantLevel = assignmantLevel
        self.otherWorkplaceIDs = otherWorkplaceIDs
    }
}

enum AssignmaneLevel: String, Codable {
    case wantedDay
    case possibleDay
}


class User: Codable {
    let id: Int
    let name: String
    var wantedDayNumbers: [Int]
    var possibleDayNumbers: [Int]
    let workPlaceIDs: [Int]
    var maxWorkingDays: Int
    
    init(id: Int, name: String, wantedDayNumbers: [Int], possibleDayNumbers: [Int], workPlaceIDs: [Int], maxWorkingDays: Int) {
        self.id = id
        self.name = name
        self.wantedDayNumbers = wantedDayNumbers
        self.possibleDayNumbers = possibleDayNumbers
        self.workPlaceIDs = workPlaceIDs
        self.maxWorkingDays = maxWorkingDays
    }
}
