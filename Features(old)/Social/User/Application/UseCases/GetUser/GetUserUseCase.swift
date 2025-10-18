//
//  GetUserUseCase.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

extension UserFeature.Application.UseCases {
    protocol GetUserUseCase {
        func execute(request: GetUserRequest) async throws -> GetUserResponse
    }
}
