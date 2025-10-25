//
//  GetPostUseCase.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/10/2025.
//

import Foundation

extension PostNamespace.Application.UseCases {
    final class GetPostUseCase {
        typealias Repository = PostNamespace.Domain.Repositories.PostRepository
        typealias Post = PostNamespace.Domain.Entities.Post
        typealias PostID = PostNamespace.Domain.ValueObjects.PostID

        private let repository: Repository

        init(repository: Repository) {
            self.repository = repository
        }

        func execute(id: PostID) async throws -> Post {
            try await repository.fetch(by: id)
        }
    }
}
