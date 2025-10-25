//
//  AsyncSequence+Extensions.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 04/10/2025.
//

import Foundation

extension Sequence {
    /// Exécute un compactMap asynchrone sur une séquence.
    func asyncCompactMap<T>(
        _ transform: @escaping (Element) async throws -> T?
    ) async rethrows -> [T] {
        var results = [T]()
        for element in self {
            if let transformed = try await transform(element) {
                results.append(transformed)
            }
        }
        return results
    }

    /// Variante sans filtrage (asyncMap)
    func asyncMap<T>(
        _ transform: @escaping (Element) async throws -> T
    ) async rethrows -> [T] {
        var results = [T]()
        for element in self {
            results.append(try await transform(element))
        }
        return results
    }
}
