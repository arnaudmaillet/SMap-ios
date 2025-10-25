//
//  MockPostFactory.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

import Foundation

extension PostNamespace.Infrastructure.Factories {
    struct MockPostFactory {
        static func makeMockPost(id: String) -> PostNamespace.Domain.Entities.Post {
            .init(
                id: .init(UUID(uuidString: id) ?? UUID()),
                authorId: .init(UUID()),
                caption: .init("Mock caption for post \(id)"),
                mediaIds: [.init(UUID())],
                score: .init(Int.random(in: 0...100)),
                createdAt: .init(Date().addingTimeInterval(-3600))
            )
        }
    }
}
