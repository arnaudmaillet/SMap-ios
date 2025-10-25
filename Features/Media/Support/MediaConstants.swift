//
//  MediaConstants.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 16/10/2025.
//

import Foundation

extension MediaNamespace.Support {
    enum MediaConstants {
        enum Cache {
            static let cacheFolderName = "MediaCache"
            static let defaultMaxSizeMB = 500
            static let defaultMaxAgeDays = 30
            static let cleanupInterval: TimeInterval = 60 * 60 * 6
        }
    }
}
