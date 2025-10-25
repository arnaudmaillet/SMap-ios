//
//  MediaDTO.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 07/10/2025.
//

import Foundation

extension MediaNamespace.Application.DTOs {
    struct MediaDTO: Codable {
        let id: String
        let type: String
        let url: String
        let width: Int
        let height: Int
        let duration: Double?
        let createdAt: String?
    }
}
