//
//  CreateUserUseCaseImpl.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/10/2025.
//

extension UserNamespace.Application.UseCases {
    struct CreateUserUseCaseImpl: CreateUserUseCase {
        typealias User = UserNamespace.Domain.Entities.User
        
        private let repository: UserNamespace.Domain.Repositories.UserRepository

        init(repository: UserNamespace.Domain.Repositories.UserRepository) {
            self.repository = repository
        }

        func execute(user: User) async throws -> User {
            try await repository.create(with: user)
        }
    }
}
