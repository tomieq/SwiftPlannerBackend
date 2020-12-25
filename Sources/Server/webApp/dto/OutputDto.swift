//
//  OutputDto.swift
//  
//
//  Created by Tomasz Kucharski on 23/12/2020.
//

import Foundation

class OutputDto: Codable {
    var schedules: [ScheduleDto]?
}

extension OutputDto: CustomDebugStringConvertible {
    var debugDescription: String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        if let jsonData = try? jsonEncoder.encode(self) {
            return String(decoding: jsonData, as: UTF8.self)
        }
        return "nil"
    }
}
