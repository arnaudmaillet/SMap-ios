//
//  PostCreatedAt.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

import Foundation

extension PostNamespace.Domain.ValueObjects {
    struct CreatedAt: Equatable {
        let date: Date

        init(_ date: Date) {
            self.date = date
        }

        var timeAgoText: String {
            let interval = -date.timeIntervalSinceNow
            let minutes = Int(interval / 60)
            let hours = minutes / 60
            return hours > 0 ? "\(hours)h" : "\(minutes)m"
        }
    }
}
