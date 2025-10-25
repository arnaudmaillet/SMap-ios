//
//  GetUserUseCase.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/10/2025.
//

import Foundation

extension UserNamespace.Application.UseCases {

    struct GetUserUseCase {
        typealias UserRepository = UserNamespace.Domain.Repositories.UserRepository
        typealias UserID = UserNamespace.Domain.ValueObjects.UserID
        typealias User = UserNamespace.Domain.Entities.User

        private let repository: UserRepository

        init(repository: UserRepository) {
            self.repository = repository
        }

        func execute(id: UserID) async throws -> User {
            try await repository.fetch(by: id)
        }
    }
}
