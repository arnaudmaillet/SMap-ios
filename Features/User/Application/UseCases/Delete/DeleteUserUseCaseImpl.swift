//
//  DeleteUserUseCaseImpl.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/10/2025.
//

extension UserNamespace.Application.UseCases {
    struct DeleteUserUseCaseImpl: DeleteUserUseCase {
        typealias UserID = UserNamespace.Domain.ValueObjects.UserID
        
        private let repository: UserNamespace.Domain.Repositories.UserRepository

        init(repository: UserNamespace.Domain.Repositories.UserRepository) {
            self.repository = repository
        }

        func execute(id: UserID) async throws {
            try await repository.delete(by: id)
        }
    }
}
