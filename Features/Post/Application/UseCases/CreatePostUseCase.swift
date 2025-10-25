//
//  CreatePostUseCase.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/10/2025.
//

import Foundation

extension PostNamespace.Application.UseCases {
    final class CreatePostUseCase {
        typealias Repository = PostNamespace.Domain.Repositories.PostRepository
        typealias Post = PostNamespace.Domain.Entities.Post

        private let repository: Repository

        init(repository: Repository) {
            self.repository = repository
        }

        func execute(_ post: Post) async throws -> Post {
            try await repository.create(with: post)
        }
    }
}
