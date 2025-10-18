//
//  Post.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 10/04/2025.
//

import UIKit
import CoreLocation
import MapKit

protocol PostRenderable {
    var thumbnailURL: URL? { get }
    var thumbnailImage: UIImage? { get set }
    var isVideo: Bool { get }
    var isVertical: Bool { get }
}

enum PostContent: Equatable {
    case media(MediaContent)
    case gallery([MediaContent])
    
    func containsMedia(withId id: UUID) -> Bool {
        switch self {
        case .media(let media):
            return media.id == id
        case .gallery(let items):
            return items.contains(where: { $0.id == id })
        }
    }
}

struct PostAuthor: Identifiable, Equatable {
    let id: UUID
    let username: String
    let avatarURL: URL?
    let followersCount: Int
}

enum Post {
    struct Model: Identifiable, Equatable {
        let id: UUID
        let coordinate: CodableCoordinate
        let text: String?
        let content: PostContent
        let score: Int
        let author: PostAuthor
        let createdAt: Date
        var comments: [Comment]

        

        init(
            id: UUID = UUID(),
            coordinate: CodableCoordinate,
            text: String?,
            content: PostContent,
            score: Int,
            author: PostAuthor,
            createdAt: Date = Date(),
            comments: [Comment] = []
        ) {
            self.id = id
            self.coordinate = coordinate
            self.text = text
            self.content = content
            self.score = score
            self.author = author
            self.createdAt = createdAt
            self.comments = comments
        }
        
        var firstMedia: MediaContent? {
            switch content {
            case .media(let media):
                return media
            case .gallery(let medias):
                return medias.first
            }
        }
        
        var mainRenderable: PostRenderable? {
            switch content {
            case .media(let media): return media
            case .gallery(let medias): return medias.first
            }
        }
        
        func media(withId id: UUID) -> MediaContent? {
            switch content {
            case .media(let media):
                return media.id == id ? media : nil
            case .gallery(let medias):
                return medias.first(where: { $0.id == id })
            }
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

extension Post.Model {
    final class MapAnnotation: NSObject, MKAnnotation {
        let id: UUID
        let coordinate: CLLocationCoordinate2D
        let thumbnail: UIImage?
        let score: Int
        let authorId: UUID

        init(
            id: UUID,
            coordinate: CLLocationCoordinate2D,
            thumbnail: UIImage?,
            score: Int,
            authorId: UUID
        ) {
            self.id = id
            self.coordinate = coordinate
            self.thumbnail = thumbnail
            self.score = score
            self.authorId = authorId
        }
        
        var codableCoordinate: CodableCoordinate {
            .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
    }
}

extension Post.Model {
    func debugPrint(prefix: String = "") {
        print("🧩 \(prefix) Post ID: \(id)")
        print("    Text: \(text ?? "nil")")
        print("    Content: \(content)")
        print("    Author ID: \(author.id)")
    }
}
