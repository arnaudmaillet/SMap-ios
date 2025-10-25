//
//  DefaultAPIClient.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 05/10/2025.
//

import Foundation

/// Implémentation concrète du client API (placeholder pour le moment)
final class DefaultAPIClient: APIClientProtocol {
    private let env: AppEnvironment
    
    init(env: AppEnvironment) {
        self.env = env
    }
    
    func get<T: Decodable>(_ endpoint: String) async throws -> T {
        let url = env.baseURL.appendingPathComponent(endpoint)
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
