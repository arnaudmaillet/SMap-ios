//
//  Post.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 26/04/2025.
//

import Foundation
import CoreLocation


extension PostFeature.Domain.Model {
    
    struct Post: Identifiable, Equatable {
        typealias MediaContent = MediaFeature.Domain.Model.MediaContent
        
        let id: UUID
        let authorId: UUID
        let caption: String?
        let media: [MediaContent]
        let score: Int
        let createdAt: Date
        var isFull: Bool
        
        init(id: UUID, authorId: UUID, caption: String?, media: [MediaContent], score: Int, createdAt: Date, isFull: Bool) {
            self.id = id
            self.authorId = authorId
            self.caption = caption
            self.media = media
            self.score = score
            self.createdAt = createdAt
            self.isFull = isFull
        }
    }
}

// MARK: - Media
//enum PostMedia: Equatable {
//    case single(Media)
//    case multiple([Media])
//}
//
//struct Post: Identifiable, Equatable {
//    let id: UUID
//    let caption: String?
//    let attachments: PostMedia
//    let authorId: UUID
//    let score: Int
//    let coordinate: CodableCoordinate
//    let createdAt: Date
//    
//    init(id: UUID, caption: String?, attachments: PostMedia, authorId: UUID, score: Int, createdAt: Date = Date(), coordinate: CodableCoordinate) {
//        self.id = id
//        self.caption = caption
//        self.attachments = attachments
//        self.authorId = authorId
//        self.score = score
//        self.coordinate = coordinate
//        self.createdAt = createdAt
//    }
//    
//    var primaryMedia: Media? {
//        switch attachments {
//        case .single(let media):
//            return media
//        case .multiple(let medias):
//            return medias.first
//        }
//    }
//    
//    func mediaFor(id: UUID) -> Media? {
//        switch attachments {
//        case .single(let media):
//            return media.id == id ? media : nil
//        case .multiple(let medias):
//            return medias.first(where: { $0.id == id })
//        }
//    }
//}
//
//enum MediaType: String, Codable, Equatable {
//    case image
//    case video
//}
//
//struct Media: Identifiable, Equatable {
//    let id: UUID
//    let url: URL
//    let type: MediaType
//    let thumbnailURL: URL?
//    let duration: TimeInterval?
//    
//    init(
//        id: UUID = UUID(),
//        url: URL,
//        type: MediaType,
//        thumbnailURL: URL? = nil,
//        duration: TimeInterval? = nil
//    ) {
//        self.id = id
//        self.url = url
//        self.type = type
//        self.thumbnailURL = thumbnailURL
//        self.duration = duration
//    }
//}
