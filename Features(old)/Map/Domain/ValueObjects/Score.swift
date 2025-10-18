//
//  Score.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

extension MapFeature.Domain.ValueObjects {

    struct Score: Equatable, Comparable {
        let value: Int

        init(_ value: Int) {
            self.value = max(0, value) // Ex. de règle métier
        }

        static func < (lhs: Score, rhs: Score) -> Bool {
            lhs.value < rhs.value
        }
    }
}
