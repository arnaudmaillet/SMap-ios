//
//  PostMapper.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 03/10/2025.
//


import Foundation

extension PostFeature.Data.Mapper {
    
    protocol PostMapping {
        typealias Post = PostFeature.Domain.Entities.Post
        typealias PostDTO = PostFeature.Data.DTO.PostDTO
        
        static func toDomain(_ dto: PostDTO) -> Post?
    }
    
    struct PostMapper {
        typealias Post = PostFeature.Domain.Entities.Post
        typealias PostDTO = PostFeature.Data.DTO.PostDTO
        
        typealias MediaType = MediaFeature.Domain.ValueObjects.MediaType
        typealias MediaDimensions = MediaFeature.Domain.ValueObjects.MediaDimensions
        typealias MediaId = MediaFeature.Domain.ValueObjects.MediaId
        typealias Media = MediaFeature.Domain.Entities.Media
        typealias MediaSourceResolving = MediaFeature.Domain.Contract.MediaSourceResolving
        typealias MediaMapper = MediaFeature.Application.Mappers.MediaMapper
        
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

            return Post(
                id: postId,
                authorId: authorId,
                caption: dto.caption,
                media: dto.media.map { MediaMapper.map($0) },
                score: dto.score,
                createdAt: createdAt,
                isFull: true
            )
        }
    }
}
