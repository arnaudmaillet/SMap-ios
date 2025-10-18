//
//  LoadFeedUseCase.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 06/10/2025.
//

import Foundation

extension PostFeature.Domain.UseCase {
    protocol FetchPostsUseCase {
        typealias Annotation = MapFeature.Domain.Model.Annotation
        typealias Post = PostFeature.Domain.Model.Post
        typealias PostAnnotation = MapFeature.Domain.Model.PostAnnotation
        
        func execute(ids: [UUID]) async throws -> [Post]
        func execute(from: PostAnnotation, within: [Annotation]) async throws -> [Post]
    }

    final class DefaultFetchPostsUseCase: FetchPostsUseCase {
        typealias PostAnnotation = MapFeature.Domain.Model.PostAnnotation
        typealias Annotation = MapFeature.Domain.Model.Annotation
        typealias PostRepository = PostFeature.Data.Repository.PostRepository
        typealias Post = PostFeature.Domain.Model.Post
        
        private let repository: PostRepository

        init(repository: PostRepository) {
            self.repository = repository
        }
        
        func execute(ids: [UUID]) async throws -> [Post] {
            try await repository.fetchPosts(ids: ids)
        }

        func execute(from annotation: PostAnnotation, within annotations: [Annotation]) async throws -> [Post] {
            let circle = annotations.enclosingGeoCircle()
            var posts = try await repository.fetchPosts(in: circle)

            // deplace le post selectionné au premier slot de la liste
            posts.move(where: { post in post.id == annotation.id }, to: 0)

            return posts
        }
    }
}
