//
//  DataSourceError.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 20/10/2025.
//

import Foundation

/// Generic, feature-scoped error type for all DataSources.
/// Works with IdentifiableComponent & ComponentID.
public enum DataSourceError<Namespace>: Error, LocalizedError, CustomStringConvertible {
    
    case network(_ source: String, _ underlying: Error)
    case mapping(_ source: String, _ underlying: Error)
    case cache(_ source: String, _ underlying: Error)
    case unauthorized(_ source: String)
    case notFound(_ source: String)
    case unknown(_ source: String, _ underlying: Error?)
    
    // MARK: - LocalizedError
    public var errorDescription: String? {
        switch self {
        case let .network(source, err):
            return "[DataSourceError<\(Namespace.self)>] [\(source)] Network error → \(err.localizedDescription)"
        case let .mapping(source, err):
            return "[DataSourceError<\(Namespace.self)>] [\(source)] Mapping error → \(err.localizedDescription)"
        case let .cache(source, err):
            return "[DataSourceError<\(Namespace.self)>] [\(source)] Cache error → \(err.localizedDescription)"
        case let .unauthorized(source):
            return "[DataSourceError<\(Namespace.self)>] [\(source)] Unauthorized access"
        case let .notFound(source):
            return "[DataSourceError<\(Namespace.self)>] [\(source)] Resource not found"
        case let .unknown(source, err):
            return "[DataSourceError<\(Namespace.self)>] [\(source)] Unknown error → \(err?.localizedDescription ?? "nil")"
        }
    }
    
    // MARK: - CustomStringConvertible
    public var description: String {
        errorDescription ?? "[DataSourceError<\(Namespace.self)>]"
    }
}


public extension DataSourceError where Namespace: Any {
    static func network<C: IdentifiableComponent>(_ component: C.Type, _ error: Error) -> Self where C.Namespace == Namespace {
        .network(component.id, error)
    }

    static func mapping<C: IdentifiableComponent>(_ component: C.Type, _ error: Error) -> Self where C.Namespace == Namespace {
        .mapping(component.id, error)
    }

    static func unknown<C: IdentifiableComponent>(_ component: C.Type, _ error: Error) -> Self where C.Namespace == Namespace {
        .unknown(component.id, error)
    }
}
