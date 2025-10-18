//
//  DefaultGetUserUseCase.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

extension UserFeature.Application.UseCases {
    final class DefaultGetUserUseCase: GetUserUseCase {
        typealias UserRepository = UserFeature.Domain.Repository.UserRepository
        
        private let repository: UserRepository
        
        init(repository: UserRepository) {
            self.repository = repository
        }
        
        func execute(request: GetUserRequest) async throws -> GetUserResponse {
            let user = try await repository.getUser(by: request.userId)
            return GetUserResponse(user: user)
        }
    }
}
