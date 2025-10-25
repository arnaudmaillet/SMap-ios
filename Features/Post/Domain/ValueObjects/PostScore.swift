//
//  Score.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import Foundation

extension PostNamespace.Domain.ValueObjects {
    struct PostScore: Equatable, Comparable {
        let value: Int

        init(_ value: Int) {
            self.value = value
        }

        static func < (lhs: PostScore, rhs: PostScore) -> Bool {
            lhs.value < rhs.value
        }

        static var zero: PostScore { PostScore(0) }
    }
}
