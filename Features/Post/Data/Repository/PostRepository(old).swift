//
//  PostRepository.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 03/10/2025.
//



import Foundation
import CoreLocation

extension PostFeature.Data.Repository {
    protocol PostRepository {
        typealias Post = PostFeature.Domain.Entities.Post
        typealias PostPreview = PostFeature.Domain.Entities.PostPreview
        typealias GeoCircle = MapFeature.Domain.Model.GeoCircle
        
        /// Récupère un post complet par son identifiant unique
        func fetchPost(id: UUID) async throws -> Post
        
        /// Récupère plusieurs posts complets à partir d'une liste d'identifiants (ex: depuis la map)
        func fetchPosts(ids: [UUID]) async throws -> [Post]
        
        /// Récupère plusieurs posts complets à partir d'un rayon sur la carte
        func fetchPosts(in circle: GeoCircle) async throws -> [Post]
        
        /// Récupère les previews des posts d’un utilisateur (pour la galerie par ex.)
        func fetchPostPreviews(in circle: GeoCircle) async throws -> [PostPreview]
    }
    
    final class RemotePostRepository: PostRepository {
        typealias Post = PostFeature.Domain.Entities.Post
        
        private let apiClient: APIClientProtocol
        
        init(apiClient: APIClientProtocol) {
            self.apiClient = apiClient
        }
        
        func fetchPost(id: UUID) async throws -> Post {
            // 🔜 À implémenter plus tard : appel réseau
            throw NSError(domain: "DefaultPostRepository", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "fetchPost not implemented"])
        }
        
        func fetchPosts(ids: [UUID]) async throws -> [Post] {
            // 🔜 À implémenter plus tard : appel réseau
            throw NSError(domain: "DefaultPostRepository", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "fetchPosts not implemented"])
        }
        
        func fetchPosts(in circle: GeoCircle) async throws -> [Post] {
            // 🔜 À implémenter plus tard : appel réseau
            throw NSError(domain: "DefaultPostRepository", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "fetchPosts(in:) not implemented"])
        }
        
        func fetchPostPreviews(in circle: GeoCircle) async throws -> [PostPreview] {
            // 🔜 À implémenter plus tard : appel réseau
            throw NSError(domain: "RemotePostRepository", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "fetchPostPreviews not implemented"])
        }
    }
    
    final class LocalPostRepository: PostRepository {
        typealias Post = PostFeature.Domain.Entities.Post
        typealias PostMapper = PostFeature.Data.Mapper.PostMapper
        typealias GeoCircle = MapFeature.Domain.Model.GeoCircle
        typealias LocalMediaSourceResolver = MediaFeature.Data.Resolver.LocalMediaSourceResolver
        
        let dataSource = AppMockDataSource.shared
        let sourceResolver = LocalMediaSourceResolver()
        
        func fetchPost(id: UUID) async throws -> Post {
            guard let dto = dataSource.posts.first(where: { post in post.id == id.uuidString }) else {
                throw NSError(domain: "MockPostRepository", code: 404,
                              userInfo: [NSLocalizedDescriptionKey: "Post not found in mocks"])
            }
            guard let post = PostMapper.toDomain(dto, sourceResolver: sourceResolver) else {
                throw NSError(domain: "MockPostRepository", code: 500,
                              userInfo: [NSLocalizedDescriptionKey: "Mapping error"])
            }
            return post
        }
        
        func fetchPosts(ids: [UUID]) async throws -> [Post] {
            let stringIds = ids.map {id in id.uuidString }
            let filtered = dataSource.posts.filter { post in stringIds.contains(post.id) }
            return filtered.compactMap { postDTO in PostMapper.toDomain(postDTO, sourceResolver: sourceResolver) }
        }
        
        func fetchPosts(in circle: GeoCircle) async throws -> [Post] {
            let center = CLLocation(latitude: circle.center.latitude, longitude: circle.center.longitude)

            // 1️⃣ Trouver les annotations dans le cercle
            let annotationsInCircle = dataSource.annotations.filter { annotationDTO in
                let location = CLLocation(latitude: annotationDTO.latitude, longitude: annotationDTO.longitude)
                return center.distance(from: location) <= circle.radius
            }

            // 2️⃣ Extraire les IDs de post correspondants
            let postIds = annotationsInCircle.map(\.id)

            // 3️⃣ Récupérer les PostDTO correspondants
            let matchingPosts = dataSource.posts.filter { post in postIds.contains(post.id) }
            
            // 4️⃣ Mapper vers le domaine
            return matchingPosts.compactMap { postDTO in PostMapper.toDomain(postDTO, sourceResolver: sourceResolver) }
        }
        
        func fetchPostPreviews(in circle: GeoCircle) async throws -> [PostPreview] {
            let center = CLLocation(latitude: circle.center.latitude, longitude: circle.center.longitude)

            // 1️⃣ Trouver les annotations dans le cercle
            let annotationsInCircle = dataSource.annotations.filter { annotationDTO in
                let location = CLLocation(latitude: annotationDTO.latitude, longitude: annotationDTO.longitude)
                return center.distance(from: location) <= circle.radius
            }

            // 2️⃣ Extraire les IDs de post correspondants
            let postIds = annotationsInCircle.map(\.id)

            // 3️⃣ Récupérer les PostDTO correspondants
            let matchingPosts = dataSource.posts.filter { post in postIds.contains(post.id) }

            // 4️⃣ Mapper en PostPreview
            return matchingPosts.compactMap { dto -> PostPreview? in
                guard let thumbnail = dto.media.first else { return nil }

                let previewDTO = PostFeature.Data.DTO.PostPreviewDTO(
                    id: dto.id,
                    authorId: dto.authorId,
                    caption: dto.caption,
                    thumbnail: thumbnail,
                    score: dto.score,
                    createdAt: dto.createdAt
                )

                return PostFeature.Data.Mapper.PostPreviewMapper.toDomain(
                    previewDTO,
                    sourceResolver: sourceResolver
                )
            }
        }
    }
}
