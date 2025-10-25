//
//  PostPreview.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 14/10/2025.
//

import Foundation

extension PostNamespace.Domain.Entities {
    
    struct PostPreview: Identifiable, Equatable {
        typealias Media = MediaFeature.Domain.Entities.Media
        
        let id: UUID
        let authorId: UUID
        let caption: String?
        let mediaPreview: Media
        let score: Int
        let createdAt: Date

        init(id: UUID, authorId: UUID, caption: String?, mediaPreview: Media, score: Int, createdAt: Date) {
            self.id = id
            self.authorId = authorId
            self.caption = caption
            self.mediaPreview = mediaPreview
            self.score = score
            self.createdAt = createdAt
        }
    }
}

//
//extension PostFeature.Domain.Entities {
//    
//    struct PostPreview: Identifiable, Equatable {
//        typealias MediaContent = MediaFeature.Domain.Model.MediaContent
//        typealias PostId = PostFeature.Domain.ValueObjects.PostId
//        typealias UserId = UserFeature.Domain.ValueObjects.UserId
//        typealias Caption = PostFeature.Domain.ValueObjects.PostCaption
//        typealias Score = PostFeature.Domain.ValueObjects.PostScore
//        typealias CreatedAt = CommonFeature.Domain.ValueObjects.CreatedAt
//        
//        let id: PostId
//        let authorId: UserId
//        let caption: Caption
//        let mediaPreview: MediaContent
//        let score: Score
//        let createdAt: CreatedAt
//
//        init(
//            id: PostId,
//            authorId: UserId,
//            caption: Caption,
//            mediaPreview: MediaContent,
//            score: Score,
//            createdAt: CreatedAt
//        ) {
//            self.id = id
//            self.authorId = authorId
//            self.caption = caption
//            self.mediaPreview = mediaPreview
//            self.score = score
//            self.createdAt = createdAt
//        }
//    }
//}
