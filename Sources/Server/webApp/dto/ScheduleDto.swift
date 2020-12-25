//
//  ScheduleDto.swift
//  
//
//  Created by Tomasz Kucharski on 23/12/2020.
//

import Foundation

class ScheduleDto: Codable {
    var workPlaceID: Int?
    var workPlaceName: String?
    var scheduledDays: [ScheduledDayDto]?
}

class ScheduledDayDto: Codable {
    var dayNumber: Int?
    var userID: Int?
}
