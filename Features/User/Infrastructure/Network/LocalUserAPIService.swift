//
//  LocalUserAPIService.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import Foundation

extension UserFeature.Infrastructure.Network {
    final class LocalUserAPIService: UserAPIService {
        typealias UserDTO = UserFeature.Application.DTOs.UserDTO
        
        private let mockUsers: [String: UserDTO]

        init(mockUsers: [UserDTO]? = nil) {
            // Génère un mock par défaut si aucun fourni
            if let provided = mockUsers {
                self.mockUsers = Dictionary(uniqueKeysWithValues: provided.map { ($0.id, $0) })
            } else {
                // Mock simple par défaut
                let dto = UserDTO(
                    id: "user_123",
                    username: "mock_user",
                    avatar: "avatar_1",
                    bio: "Mock user for testing",
                    followers: 123,
                    following: 45,
                    postCount: 8
                )
                self.mockUsers = [dto.id: dto]
            }
        }

        func fetchUser(id: String) async throws -> UserDTO {
            if let user = mockUsers[id] {
                return user
            } else {
                throw NSError(domain: "MockUserAPIService", code: 404, userInfo: [
                    NSLocalizedDescriptionKey: "User not found in mock data"
                ])
            }
        }
    }
}
