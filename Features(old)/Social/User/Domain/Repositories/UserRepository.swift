//
//  UserRepository.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

extension UserFeature.Domain.Repository {
    protocol UserRepository {
        typealias User = UserFeature.Domain.Entities.User
        func getUser(by id: String) async throws -> User
    }
}
