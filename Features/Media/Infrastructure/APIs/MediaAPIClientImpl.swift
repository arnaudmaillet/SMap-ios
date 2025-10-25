//
//  MediaAPIClientImpl.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 22/10/2025.
//

import Foundation

extension MediaNamespace.Infrastructure.APIs {
    final class MediaAPIClientImpl: MediaAPIClient {
        
        typealias MediaDTO = MediaNamespace.Application.DTOs.MediaDTO
        
        // MARK: - Dependencies
        private let baseURL: URL
        
        // MARK: - Init
        init(baseURL: URL) {
            self.baseURL = baseURL
        }
        
        // MARK: - API Calls
        
        /// Récupère un média unique
        func fetch(by id: String) async throws -> MediaDTO {
            let endpoint = MediaAPIEndpoints.fetch(by: id, baseURL: baseURL)
            var request = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            return try await APIRequestExecutor.perform(request)
        }

        /// Crée un nouveau média
        func create(with media: MediaDTO) async throws -> MediaDTO {
            let endpoint = MediaAPIEndpoints.create(baseURL: baseURL)
            var request = URLRequest(url: endpoint)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(media)
            return try await APIRequestExecutor.perform(request)
        }

        /// Met à jour un média existant
        func update(with media: MediaDTO) async throws -> MediaDTO {
            let endpoint = MediaAPIEndpoints.update(baseURL: baseURL)
            var request = URLRequest(url: endpoint)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(media)
            return try await APIRequestExecutor.perform(request)
        }

        /// Supprime un média
        func delete(by id: String) async throws {
            let endpoint = MediaAPIEndpoints.delete(by: id, baseURL: baseURL)
            var request = URLRequest(url: endpoint)
            request.httpMethod = "DELETE"
            _ = try await APIRequestExecutor.perform(request) as EmptyResponse
        }

        // MARK: - Batch Operations
        
        /// Récupère plusieurs médias à partir d'une liste d'IDs
        func batchFetch(by ids: [String]) async throws -> [MediaDTO] {
            let idList = ids.joined(separator: ",")
            let endpoint = MediaAPIEndpoints.batchFetch(ids: idList, baseURL: baseURL)
            var request = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            return try await APIRequestExecutor.perform(request)
        }

        /// Crée plusieurs médias à la fois (ex: lors de la création d’un post)
        func batchCreate(with medias: [MediaDTO]) async throws -> [MediaDTO] {
            let endpoint = MediaAPIEndpoints.batchCreate(baseURL: baseURL)
            var request = URLRequest(url: endpoint)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(medias)
            return try await APIRequestExecutor.perform(request)
        }

        /// Met à jour plusieurs médias à la fois
        func batchUpdate(with medias: [MediaDTO]) async throws -> [MediaDTO] {
            let endpoint = MediaAPIEndpoints.batchUpdate(baseURL: baseURL)
            var request = URLRequest(url: endpoint)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(medias)
            return try await APIRequestExecutor.perform(request)
        }

        /// Supprime plusieurs médias à la fois
        func batchDelete(by ids: [String]) async throws {
            let idList = ids.joined(separator: ",")
            let endpoint = MediaAPIEndpoints.batchDelete(ids: idList, baseURL: baseURL)
            var request = URLRequest(url: endpoint)
            request.httpMethod = "DELETE"
            _ = try await APIRequestExecutor.perform(request) as EmptyResponse
        }
    }
}
