//
//  MediaContent.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 07/10/2025.
//

import Foundation

extension MediaFeature.Domain.Entities {
    struct MediaContent: Identifiable, Equatable {
        typealias MediaId = MediaFeature.Domain.ValueObjects.MediaId
        typealias MediaType = MediaFeature.Domain.ValueObjects.MediaType
        typealias MediaDimensions = MediaFeature.Domain.ValueObjects.MediaDimensions
        
        let id: MediaId
        let type: MediaType
        let url: URL
        let dimensions: MediaDimensions
        let duration: TimeInterval?

        var isVideo: Bool { type == .video }
        var aspectRatio: CGFloat { dimensions.aspectRatio }
    }
}

