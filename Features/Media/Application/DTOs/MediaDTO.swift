//
//  MediaDTO.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 07/10/2025.
//

import Foundation

extension MediaFeature.Application.DTOs {
    struct MediaDTO: Codable, Equatable {
        let id: UUID
        let type: String               // "image" ou "video"
        let url: URL
        let width: Int
        let height: Int
        let duration: TimeInterval?
    }
}
