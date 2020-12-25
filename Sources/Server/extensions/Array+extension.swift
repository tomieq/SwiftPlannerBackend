//
//  Array+extension.swift
//  
//
//  Created by Tomasz Kucharski on 26/12/2020.
//

import Foundation

extension Array {
    func count(match: (Element) -> Bool) -> Int {
        var count: Int = 0
        for x in self {
            if match(x) {
                count = count + 1
            }
        }
        return count
    }
}
