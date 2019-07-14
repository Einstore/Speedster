//
//  File.swift
//  
//
//  Created by Ondrej Rafaj on 13/07/2019.
//

import Foundation


extension Array where Element: Hashable {
    
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
    
}