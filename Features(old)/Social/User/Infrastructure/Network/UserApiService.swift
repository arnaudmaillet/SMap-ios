//
//  UserApiService.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

extension UserFeature.Infrastructure.Network {
    protocol UserAPIService {
        typealias UserDTO = UserFeature.Application.DTOs.UserDTO
        func fetchUser(id: String) async throws -> UserDTO
    }
}
