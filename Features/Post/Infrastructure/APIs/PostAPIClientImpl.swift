//
//  DefaultPostAPIClient.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

import Foundation

extension PostFeature.Infrastructure.APIs {
    final class DefaultPostAPIClient: PostAPIClient {
        typealias PostDTO = PostFeature.Application.DTOs.PostDTO
        
        func fetchPost(id: String) async throws -> PostDTO {
            let url = URL(string: "https://api.socialmap.app/posts/\(id)")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode(PostDTO.self, from: data)
        }
    }
}
