//
//  FetchPostDetailUseCase.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 07/10/2025.
//

import Foundation

//extension PostFeature.Domain.UseCase {
//    protocol FetchPostDetailsUseCase {
//        typealias Post = PostFeature.Domain.Model.Post
//        func execute(ids: [UUID]) async throws -> [Post]
//    }
//
//    final class DefaultFetchPostDetailsUseCase: FetchPostDetailsUseCase {
//        typealias PostRepository = PostFeature.Data.Repository.PostRepository
//        typealias Post = PostFeature.Domain.Model.Post
//        
//        private let repository: PostRepository
//
//        init(repository: PostRepository) {
//            self.repository = repository
//        }
//
//        func execute(ids: [UUID]) async throws -> [Post] {
//            try await repository.fetchPosts(ids: ids)
//        }
//    }
//}
