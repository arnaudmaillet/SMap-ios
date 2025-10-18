//
//  PostMock.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 03/10/2025.
//


import Foundation

extension PostFeature.Data.Mock {
    struct PostMockFactory {
        typealias PostDTO = PostFeature.Data.DTO.PostDTO
        static func makeCollection(count: Int = 20) -> [PostDTO] {
            (0..<count).compactMap { _ in
                // 🖼️ Sélection aléatoire d’un nom d’image locale
                guard let imageName = MockAssets.imagesURL.randomElement() else { return nil }
                
                return PostDTO(
                    id: UUID().uuidString,
                    authorId: UUID().uuidString,
                    caption: MockText.randomCaption(),
                    media: [
                        .init(
                            id: UUID().uuidString,
                            type: "image",
                            path: imageName
                        )
                    ],
                    thumbnailRef: .asset(name: imageName),
                    score: Int.random(in: 0...100),
                    createdAt: ISO8601DateFormatter().string(from: Date())
                )
            }
        }
    }

    enum MockText {
        static let captions = [
            "Un superbe coucher de soleil 🌇",
            "Moment parfait ☕️",
            "C’est ici que tout a commencé 💫",
            "Exploration urbaine 🏙️",
            "Instant magique 🌊"
        ]
        
        static func randomCaption() -> String {
            captions.randomElement()!
        }
    }
}
