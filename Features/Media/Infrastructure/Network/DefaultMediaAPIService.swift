//
//  MediaAPIService.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import Foundation

extension MediaFeature.Infrastructure.Network {
    final class MediaAPIService {
        typealias MediaId = MediaFeature.Domain.ValueObjects.MediaId
        typealias MediaDTO = MediaFeature.Application.DTOs.MediaDTO
        
        private let environment: AppEnvironment
        private let baseURL: URL

        init(environment: AppEnvironment) {
            self.environment = environment
            switch environment {
            case .dev:
                self.baseURL = URL(string: "https://api-dev.socialmap.app/media")!
            case .prod:
                self.baseURL = URL(string: "https://api.socialmap.app/media")!
            case .mock:
                fatalError("MediaAPIService should not be used in mock environment")
            }
        }

        func fetchMediaDTO(by id: MediaId) async throws -> MediaDTO {
            let url = baseURL.appendingPathComponent(id.value.uuidString)
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NSError(domain: "MediaAPIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch media"])
            }

            return try JSONDecoder().decode(MediaDTO.self, from: data)
        }

        func fetchBatchMediaDTOs(for ids: [MediaId]) async throws -> [MediaDTO] {
            let idList = ids.map { $0.value.uuidString }.joined(separator: ",")
            
            var components = URLComponents(url: baseURL.appendingPathComponent("batch"), resolvingAgainstBaseURL: false)
            components?.queryItems = [URLQueryItem(name: "ids", value: idList)]

            guard let url = components?.url else {
                throw NSError(domain: "MediaAPIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NSError(domain: "MediaAPIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to preload media list"])
            }

            return try JSONDecoder().decode([MediaDTO].self, from: data)
        }
    }
}
