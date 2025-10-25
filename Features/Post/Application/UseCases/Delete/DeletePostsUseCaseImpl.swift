//
//  DeletePostsUseCase.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 20/10/2025.
//


import Foundation

extension PostNamespace.Application.UseCases {
    final class DeletePostsUseCase {
        typealias Repository = PostNamespace.Domain.Repositories.PostRepository
        typealias PostID = PostNamespace.Domain.ValueObjects.PostID

        private let repository: Repository

        init(repository: Repository) {
            self.repository = repository
        }

        func execute(ids: [PostID]) async throws {
            try await repository.batchDelete(by: ids)
        }
    }
}
