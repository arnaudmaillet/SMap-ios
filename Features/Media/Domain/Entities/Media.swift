//
//  MediaContent.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 07/10/2025.
//

import Foundation

extension MediaNamespace.Domain.Entities {
    struct Media: Identifiable, Equatable {
        typealias MediaId = MediaNamespace.Domain.ValueObjects.MediaId
        typealias MediaType = MediaNamespace.Domain.ValueObjects.MediaType
        typealias MediaDimensions = MediaNamespace.Domain.ValueObjects.MediaDimensions
        
        let id: MediaId
        let type: MediaType
        let url: URL
        let dimensions: MediaDimensions
        let duration: TimeInterval?

        var isVideo: Bool { type == .video }
        var aspectRatio: CGFloat { dimensions.aspectRatio }
    }
}

