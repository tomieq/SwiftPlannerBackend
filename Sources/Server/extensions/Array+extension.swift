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

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = firstIndex(of: object) {
            remove(at: index)
        }
    }
}
