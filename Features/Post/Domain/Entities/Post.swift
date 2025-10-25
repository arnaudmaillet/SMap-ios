//
//  Post.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 26/04/2025.
//

import Foundation

extension PostNamespace.Domain.Entities {
    struct Post: Identifiable, Equatable {
        typealias PostId = PostNamespace.Domain.ValueObjects.PostId
        typealias UserId = PostNamespace.Domain.ValueObjects.UserId
        typealias MediaId = PostNamespace.Domain.ValueObjects.MediaId
        typealias Score = PostNamespace.Domain.ValueObjects.PostScore
        typealias CreatedAt = PostNamespace.Domain.ValueObjects.CreatedAt
        typealias Caption = PostNamespace.Domain.ValueObjects.Caption
        
        let id: PostId
        let authorId: UserId
        let caption: Caption?
        let mediaIds: [MediaId]
        let score: Score
        let createdAt: CreatedAt

        init(
            id: PostId,
            authorId: UserId,
            caption: Caption?,
            mediaIds: [MediaId],
            score: Score,
            createdAt: CreatedAt,
        ) {
            self.id = id
            self.authorId = authorId
            self.caption = caption
            self.mediaIds = mediaIds
            self.score = score
            self.createdAt = createdAt
        }
    }
}
