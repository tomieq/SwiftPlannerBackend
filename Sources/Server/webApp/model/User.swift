//
//  User.swift
//  
//
//  Created by Tomasz Kucharski on 29/12/2020.
//

import Foundation

class User: Codable {
    let id: Int
    let name: String
    var wantedDayNumbers: [Int]
    var possibleDayNumbers: [Int]
    let workPlaceIDs: [Int]
    var maxWorkingDays: Int
    var wishes: UserWishes
    
    init(id: Int, name: String, wantedDayNumbers: [Int], possibleDayNumbers: [Int], workPlaceIDs: [Int], wishes: UserWishes, maxWorkingDays: Int) {
        self.id = id
        self.name = name
        self.wantedDayNumbers = wantedDayNumbers
        self.possibleDayNumbers = possibleDayNumbers
        self.workPlaceIDs = workPlaceIDs
        self.wishes = wishes
        self.maxWorkingDays = maxWorkingDays
    }
    
    init(from snapshot: UserSnapshot) {
        self.id = snapshot.id
        self.name = snapshot.name
        self.wantedDayNumbers = snapshot.wantedDayNumbers
        self.possibleDayNumbers = snapshot.possibleDayNumbers
        self.workPlaceIDs = snapshot.workPlaceIDs
        self.maxWorkingDays = snapshot.maxWorkingDays
        self.wishes = UserWishes(from: snapshot.wishes)
    }
}
