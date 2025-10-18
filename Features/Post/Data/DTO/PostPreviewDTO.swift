//
//  PostPreviewDTO.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 14/10/2025.
//

import Foundation

extension PostFeature.Data.DTO {
    
    struct PostPreviewDTO: Codable {
        typealias MediaDTO = MediaFeature.Data.DTO.MediaDTO
        let id: String
        let authorId: String
        let caption: String?
        let thumbnail: MediaDTO
        let score: Int
        let createdAt: String
    }
}
