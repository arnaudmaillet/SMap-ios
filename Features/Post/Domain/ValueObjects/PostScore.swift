//
//  Score.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import Foundation

struct Score: Equatable, Comparable {
    let value: Int
    
    init(_ value: Int) {
        guard value >= 0 else {
            fatalError("Score cannot be negative.")
        }
        self.value = value
    }
    
    static func < (lhs: Score, rhs: Score) -> Bool {
        lhs.value < rhs.value
    }
}
