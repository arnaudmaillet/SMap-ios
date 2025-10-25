//
//  UpdateUseCase.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/10/2025.
//

extension UserNamespace.Application.UseCases {
    protocol UpdateUserUseCase {
        typealias User = UserNamespace.Domain.Entities.User

        func execute(user: User) async throws -> User
    }
}
