//
//  PostPreviewMapper.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 14/10/2025.
//

import Foundation

extension PostFeature.Data.Mapper {

    protocol PostPreviewMapping {
        typealias PostPreview = PostFeature.Domain.Model.PostPreview
        typealias PostPreviewDTO = PostFeature.Data.DTO.PostPreviewDTO

        static func toDomain(_ dto: PostPreviewDTO) -> PostPreview?
    }

    struct PostPreviewMapper {
        typealias PostPreview = PostFeature.Domain.Model.PostPreview
        typealias PostPreviewDTO = PostFeature.Data.DTO.PostPreviewDTO

        typealias MediaType = MediaFeature.Domain.Model.MediaType
        typealias MediaContent = MediaFeature.Domain.Model.MediaContent
        typealias MediaSourceResolving = MediaFeature.Domain.Contract.MediaSourceResolving

        static func toDomain(
            _ dto: PostPreviewDTO,
            sourceResolver: MediaSourceResolving
        ) -> PostPreview? {
            guard
                let rawPostId = UUID(uuidString: dto.id)
                    .logFailure("postPreview.id invalide : \(dto.id)"),
                let rawAuthorId = UUID(uuidString: dto.authorId)
                    .logFailure("author.id invalide : \(dto.authorId)"),
                let createdAt = ISO8601DateFormatter().date(from: dto.createdAt)
                    .logFailure("createdAt invalide : \(dto.createdAt)"),
                let type = MediaType(rawValue: dto.thumbnail.type)
                    .logFailure("MediaType invalide : \(dto.thumbnail.type)"),
                let source = sourceResolver.resolveSource(from: dto.thumbnail.path)
                    .logFailure("Source introuvable pour path: \(dto.thumbnail.path)"),
                let rawMediaId = UUID(uuidString: dto.thumbnail.id)
                    .logFailure("UUID invalide pour mediaId: \(dto.thumbnail.id)")
            else {
                return nil
            }

            let postId = UUID.namespaced(from: rawPostId, namespace: IDNamespace.post)
            let authorId = UUID.namespaced(from: rawAuthorId, namespace: IDNamespace.author)
            let mediaId = UUID.namespaced(from: rawMediaId, namespace: IDNamespace.media)

            let mediaPreview = MediaContent(
                id: mediaId,
                type: type,
                source: source
            )

            return PostPreview(
                id: postId,
                authorId: authorId,
                caption: dto.caption,
                mediaPreview: mediaPreview,
                score: dto.score,
                createdAt: createdAt
            )
        }
    }
}
