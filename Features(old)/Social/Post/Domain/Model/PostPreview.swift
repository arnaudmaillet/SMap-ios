//
//  PostPreview.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 14/10/2025.
//

import Foundation

extension PostFeature.Domain.Model {
    
    struct PostPreview: Identifiable, Equatable {
        typealias MediaContent = MediaFeature.Domain.Model.MediaContent
        
        let id: UUID
        let authorId: UUID
        let caption: String?
        let mediaPreview: MediaContent
        let score: Int
        let createdAt: Date

        init(id: UUID, authorId: UUID, caption: String?, mediaPreview: MediaContent, score: Int, createdAt: Date) {
            self.id = id
            self.authorId = authorId
            self.caption = caption
            self.mediaPreview = mediaPreview
            self.score = score
            self.createdAt = createdAt
        }
    }
}
