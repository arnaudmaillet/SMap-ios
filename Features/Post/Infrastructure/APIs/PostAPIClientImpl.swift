//
//  PostAPIClientImpl.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

import Foundation

extension PostNamespace.Infrastructure.APIs {
    final class PostAPIClientImpl: PostAPIClient {
        typealias PostDTO = PostNamespace.Application.DTOs.PostDTO

        func fetchPost(id: String) async throws -> PostDTO {
            let url = URL(string: "https://api.socialmap.app/posts/\(id)")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                throw URLError(.badServerResponse)
            }

            do {
                return try JSONDecoder().decode(PostDTO.self, from: data)
            } catch {
                throw URLError(.cannotDecodeRawData)
            }
        }
    }
}
