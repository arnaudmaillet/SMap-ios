//
//  PostDTO.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 02/10/2025.
//

import Foundation

extension PostFeature.Data.DTO {
    
    struct PostDTO: Codable {
        typealias MediaDTO = MediaFeature.Data.DTO.MediaDTO
        
        let id: String
        let authorId: String
        let caption: String?
        let media: [MediaDTO]
        let thumbnailRef: ThumbnailReference?
        let score: Int
        let createdAt: String
    }
}
