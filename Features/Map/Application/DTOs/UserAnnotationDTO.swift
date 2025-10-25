//
//  UserAnnotationDataDTO.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 23/10/2025.
//

extension MapNamespace.Application.DTOs {
    struct UserAnnotationDataDTO: Codable, Equatable {
        let id: String
        let username: String
        let displayName: String?
        let avatarURL: String?
        let isVerified: Bool?
        let status: String?            // "online", "exploring", "recording"
    }
}
