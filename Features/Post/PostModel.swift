//
//  Post.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 10/04/2025.
//

import Foundation
import CoreLocation

extension Post {
    struct Model: Identifiable, Equatable {
        let id: UUID
        let coordinate: CodableCoordinate
        let content: PostContent
        let score: Int
        let author: User
        let createdAt: Date
        var comments: [Comment]

        init(
            id: UUID = UUID(),
            coordinate: CodableCoordinate,
            content: PostContent,
            score: Int,
            author: User,
            createdAt: Date = Date(),
            comments: [Comment] = []
        ) {
            self.id = id
            self.coordinate = coordinate
            self.content = content
            self.score = score
            self.author = author
            self.createdAt = createdAt
            self.comments = comments
        }
    }
    
    struct Comment: Identifiable, Equatable {
        let id: UUID
        let author: User
        let text: String
        let createdAt: Date

        init(id: UUID = UUID(), author: User, text: String, createdAt: Date = Date()) {
            self.id = id
            self.author = author
            self.text = text
            self.createdAt = createdAt
        }
    }
}
