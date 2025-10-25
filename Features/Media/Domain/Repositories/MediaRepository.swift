//
//  MediaRepository.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

extension MediaNamespace.Domain.Repositories {
    protocol MediaRepository {
        typealias MediaId = MediaNamespace.Domain.ValueObjects.MediaId
        typealias Media = MediaNamespace.Domain.Entities.Media
        
        func loadMedia(by id: MediaId) async throws -> Media
        func preloadMedia(for ids: [MediaId]) async
    }
}
