//
//  RemoteUserAPIService.swift.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import Foundation

extension UserFeature.Infrastructure.Network {
    final class RemoteUserAPIService: UserAPIService {
        typealias UserDTO = UserFeature.Application.DTOs.UserDTO
        func fetchUser(id: String) async throws -> UserDTO {
            guard let url = URL(string: "https://api.socialmap.com/users/\(id)") else {
                throw URLError(.badURL)
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }

            return try JSONDecoder().decode(UserDTO.self, from: data)
        }
    }
}
