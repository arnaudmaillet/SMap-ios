//
//  CreateUserUseCase.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/10/2025.
//

extension UserNamespace.Application.UseCases {
    protocol CreateUserUseCase {
        typealias User = UserNamespace.Domain.Entities.User

        func execute(user: User) async throws -> User
    }
}
