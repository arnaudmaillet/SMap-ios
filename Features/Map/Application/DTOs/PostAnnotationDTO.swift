//
//  PostAnnotationDataDTO.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 23/10/2025.
//

extension MapNamespace.Application.DTOs {
    struct PostAnnotationDataDTO: Codable, Equatable {
        let id: String
        let mediaURL: String
        let mediaType: String?        // "image", "gif", "video", etc.
        let mediaWidth: Int?
        let mediaHeight: Int?
        let caption: String?
        let authorUsername: String?
        let authorAvatarURL: String?
        let hasAudio: Bool?
        let blurHash: String?
        let isNSFW: Bool?
    }
}
