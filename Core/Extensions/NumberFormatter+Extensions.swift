//
//  NumberFormatter+Extensions.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 20/04/2025.
//

import Foundation

enum FormatterUtils {
    static func formatFollowers(_ count: Int) -> String {
        switch count {
        case 1_000_000...:
            return String(format: "%.1fM", Double(count) / 1_000_000)
        case 1_000...:
            return String(format: "%.1fk", Double(count) / 1_000)
        default:
            return "\(count)"
        }
    }
}
