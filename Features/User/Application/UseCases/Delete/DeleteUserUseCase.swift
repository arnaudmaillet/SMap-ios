//
//  DeleteUserUseCase.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/10/2025.
//

extension UserNamespace.Application.UseCases {
    protocol DeleteUserUseCase {
        typealias UserID = UserNamespace.Domain.ValueObjects.UserID

        func execute(id: UserID) async throws
    }
}
