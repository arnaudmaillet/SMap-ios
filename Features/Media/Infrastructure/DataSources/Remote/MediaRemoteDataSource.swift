//
//  MediRemoteDataSource.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 22/10/2025.
//


import Foundation

extension MediaNamespace.Infrastructure.DataSources {
    /// Représente la source de vérité distante pour les objets `Media`.
    /// Implemente les appels aux APIs externes via `MediaAPIClient`.
    protocol MediaRemoteDataSource {
        typealias Media = MediaNamespace.Domain.Entities.Media
        typealias MediaID = MediaNamespace.Domain.ValueObjects.MediaID

        // MARK: - Single Resource

        func fetch(by id: MediaID) async throws -> Media
        func create(with media: Media) async throws -> Media
        func update(with media: Media) async throws -> Media
        func delete(by id: MediaID) async throws

        // MARK: - Batch Operations

        func batchFetch(by ids: [MediaID]) async throws -> [Media]
        func batchCreate(with medias: [Media]) async throws -> [Media]
        func batchUpdate(with medias: [Media]) async throws -> [Media]
        func batchDelete(by ids: [MediaID]) async throws
    }
}
