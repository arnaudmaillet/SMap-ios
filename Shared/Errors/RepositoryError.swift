//
//  RepositoryError.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 19/10/2025.
//

import Foundation

/// Generic, feature-scoped error type for all Repositories.
/// Works with IdentifiableComponent & ComponentID.
public enum RepositoryError<Feature>: Error, LocalizedError, CustomStringConvertible {
    case dataSource(_ source: String, _ underlying: Error)
    case notFound(_ source: String)
    case cacheMiss(_ source: String)
    case unknown(_ source: String, _ underlying: Error?)

    public var errorDescription: String? {
        switch self {
        case let .dataSource(source, err):
            return "[RepositoryError<\(Feature.self)>] [\(source)] DataSource error → \(err.localizedDescription)"
        case let .notFound(source):
            return "[RepositoryError<\(Feature.self)>] [\(source)] Resource not found"
        case let .cacheMiss(source):
            return "[RepositoryError<\(Feature.self)>] [\(source)] No cached data available"
        case let .unknown(source, err):
            return "[RepositoryError<\(Feature.self)>] [\(source)] Unknown error → \(err?.localizedDescription ?? "nil")"
        }
    }

    public var description: String { errorDescription ?? "" }
}
