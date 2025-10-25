//
//  LoadUserFileUseCase.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 24/10/2025.
//

import Foundation

extension UserNamespace.Application.UseCases {
    protocol LoadUserFileUseCase {
        typealias User = UserNamespace.Domain.Entities.User
        
        func execute(for user: User) async throws -> Data
    }
}
