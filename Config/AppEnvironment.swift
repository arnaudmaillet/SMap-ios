//
//  AppEnvironment.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 02/10/2025.
//

import Foundation

enum AppEnvironment: String {
    case prod
    case dev
    case mock
    
    /// Base URL pour les appels API (futur)
    var baseURL: URL {
        switch self {
        case .prod:
            return URL(string: "https://api.socialmap.app")!
        case .dev:
            return URL(string: "https://dev.socialmap.app")!
        case .mock:
            return URL(string: "https://mock.local")!
        }
    }
    
    var dataSourceConfig: AppDataSourceConfig {
            switch self {
            case .prod:
                return .init(defaults: .init(
                    globalDelay: 0,
                    shouldSimulateFailure: false
                ))

            case .dev:
                return .init(defaults: .init(
                    globalDelay: 0,
                    shouldSimulateFailure: false
                ))

            case .mock:
                return .init(defaults: .init(
                    globalDelay: 0,
                    shouldSimulateFailure: false
                ))
            }
        }
}
