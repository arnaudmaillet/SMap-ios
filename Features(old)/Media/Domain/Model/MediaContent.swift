//
//  MediaContent.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 07/10/2025.
//

import Foundation

extension MediaFeature.Domain.Model {
    public struct MediaContent: Equatable {
        public let id: UUID
        public let type: MediaType
        public let source: MediaSource
    }
}

