//
//  PostMapper.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 03/10/2025.
//


import Foundation

extension PostFeature.Data.Mapper {
    
    protocol PostMapping {
        typealias Post = PostFeature.Domain.Model.Post
        typealias PostDTO = PostFeature.Data.DTO.PostDTO
        
        static func toDomain(_ dto: PostDTO) -> Post?
    }
    
    struct PostMapper {
        typealias Post = PostFeature.Domain.Model.Post
        typealias PostDTO = PostFeature.Data.DTO.PostDTO
        
        typealias MediaType = MediaFeature.Domain.Model.MediaType
        typealias MediaContent = MediaFeature.Domain.Model.MediaContent
        typealias MediaSourceResolving = MediaFeature.Domain.Contract.MediaSourceResolving
        
        static func toDomain(
            _ dto: PostDTO,
            sourceResolver: MediaSourceResolving
        ) -> Post? {
            
            guard
                let rawPostId = UUID(uuidString: dto.id)
                    .logFailure("post.id invalide : \(dto.id)"),
                let rawAuthorId = UUID(uuidString: dto.authorId)
                    .logFailure("author.id invalide : \(dto.authorId)"),
                let createdAt = ISO8601DateFormatter().date(from: dto.createdAt)
                    .logFailure("createdAt invalide : \(dto.createdAt)")
            else {
                return nil
            }

            let postId = UUID.namespaced(from: rawPostId, namespace: IDNamespace.post)
            let authorId = UUID.namespaced(from: rawAuthorId, namespace: IDNamespace.author)
            

            let media = dto.media.compactMap { mediaDTO -> MediaContent? in
                guard
                    let type = MediaType(rawValue: mediaDTO.type)
                        .logFailure("❌ MediaType invalide: \(mediaDTO.type) dans post \(dto.id)"),
                    let source = sourceResolver.resolveSource(from: mediaDTO.path)
                        .logFailure("❌ Source introuvable pour path: \(mediaDTO.path)"),
                    let rawMediaId = UUID(uuidString: mediaDTO.id)
                        .logFailure("❌ UUID invalide pour mediaId: \(mediaDTO.id)")
                else {
                    return nil
                }

                let mediaId = UUID.namespaced(from: rawMediaId, namespace: IDNamespace.media)

                return MediaContent(
                    id: mediaId,
                    type: type,
                    source: source
                )
            }

            return Post(
                id: postId,
                authorId: authorId,
                caption: dto.caption,
                media: media,
                score: dto.score,
                createdAt: createdAt,
                isFull: true
            )
        }
    }
}
