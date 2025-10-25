//
//  DeletePostUseCase.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/10/2025.
//

import Foundation

extension PostNamespace.Application.UseCases {
    final class DeletePostUseCase {
        typealias Repository = PostNamespace.Domain.Repositories.PostRepository
        typealias PostID = PostNamespace.Domain.ValueObjects.PostID

        private let repository: Repository

        init(repository: Repository) {
            self.repository = repository
        }

        func execute(id: PostID) async throws {
            try await repository.delete(by: id)
        }
    }
}
