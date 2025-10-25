//
//  MediaAPIClient.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 22/10/2025.
//

import Foundation

extension MediaNamespace.Infrastructure.APIs {
    /// Définit les opérations réseau disponibles pour les médias.
    /// Implémenté par `MediaAPIClientImpl` (via HTTP, GraphQL ou WebSocket selon le backend).
    protocol MediaAPIClient {
        typealias MediaDTO = MediaNamespace.Application.DTOs.MediaDTO

        // MARK: - Single Resource

        /// Récupère un média par son identifiant unique.
        func fetch(by id: String) async throws -> MediaDTO

        /// Crée un média unique (upload de métadonnées).
        func create(with media: MediaDTO) async throws -> MediaDTO

        /// Met à jour les informations d’un média existant.
        func update(with media: MediaDTO) async throws -> MediaDTO

        /// Supprime un média existant.
        func delete(by id: String) async throws

        // MARK: - Batch Operations

        /// Récupère plusieurs médias par leurs identifiants.
        func batchFetch(by ids: [String]) async throws -> [MediaDTO]

        /// Crée plusieurs médias en une seule requête (ex: lors de la création d’un post contenant une galerie).
        func batchCreate(with medias: [MediaDTO]) async throws -> [MediaDTO]

        /// Met à jour plusieurs médias à la fois (ex: modération groupée).
        func batchUpdate(with medias: [MediaDTO]) async throws -> [MediaDTO]

        /// Supprime plusieurs médias à la fois.
        func batchDelete(by ids: [String]) async throws
    }
}
