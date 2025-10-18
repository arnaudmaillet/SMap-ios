//
//  AppEnvironment.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 02/10/2025.
//

import Foundation

enum Environment: String {
    case prod
    case dev
    case mock

    static var current: Environment {
        let raw = ProcessInfo.processInfo.environment["APP_ENV"] ?? "prod"
        return Environment(rawValue: raw.lowercased()) ?? .prod
    }
}

enum AppEnvironment {
    static var environment: Environment {
        let raw = ProcessInfo.processInfo.environment["APP_ENV"] ?? "prod"
        return Environment(rawValue: raw.lowercased()) ?? .prod
    }

    static var postRepository: PostRepository {
        switch environment {
        case .prod, .dev:
            return PostRepositoryImpl(
                remote: PostRemoteDataSourceImpl(client: APIClient()),
                local: InMemoryPostCache()
            )
        case .mock:
            return PostRepositoryImpl(
                remote: PostRemoteDataSourceImpl(client: APIClient()),
                local: InMemoryPostCache(),
                mock: PostMockDataSource(),
                useMock: true
            )
        }
    }
}
