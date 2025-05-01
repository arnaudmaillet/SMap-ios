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
        
        init(
            id: UUID = UUID(),
            coordinate: CodableCoordinate,
            content: PostContent,
            score: Int,
            author: User,
            createdAt: Date = Date()
        ) {
            self.id = id
            self.coordinate = coordinate
            self.content = content
            self.score = score
            self.author = author
            self.createdAt = createdAt
        }
    }
}
