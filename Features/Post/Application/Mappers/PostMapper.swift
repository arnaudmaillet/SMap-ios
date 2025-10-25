//
//  PostMapper.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

import Foundation

extension PostNamespace.Application.Mappers {
    struct PostMapper {
        typealias Error = SharedNamespace.Application.Mappers.SharedMappingError
        typealias PostDTO = PostNamespace.Application.DTOs.PostDTO
        typealias Post = PostNamespace.Domain.Entities.Post

        static func toDomain(_ dto: PostDTO) throws -> Post {
            guard let postUUID = UUID(uuidString: dto.id),
                  let authorUUID = UUID(uuidString: dto.authorId),
                  let createdAt = ISO8601DateFormatter().date(from: dto.createdAt)
            else {
                throw Error.invalidFormat(
                    context: "PostMapper",
                    details: "Invalid UUID or date (id: \(dto.id), authorId: \(dto.authorId), createdAt: \(dto.createdAt))"
                )
            }

            return .init(
                id: .init(postUUID),
                authorId: .init(authorUUID),
                caption: dto.caption.map { .init($0) },
                mediaIds: dto.mediaIds.compactMap { UUID(uuidString: $0) }.map { .init($0) },
                score: .init(dto.score),
                createdAt: .init(createdAt)
            )
        }

        static func toDTO(_ domain: Post) -> PostDTO {
            .init(
                id: domain.id.value.uuidString,
                authorId: domain.authorId.value.uuidString,
                caption: domain.caption?.value,
                mediaIds: domain.mediaIds.map { $0.value.uuidString },
                score: domain.score.value,
                createdAt: ISO8601DateFormatter().string(from: domain.createdAt.date)
            )
        }
    }
}
