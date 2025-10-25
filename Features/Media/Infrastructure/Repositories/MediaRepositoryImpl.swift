//
//  MediaRepositoryImpl.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import Foundation

extension MediaNamespace.Infrastructure.Repositories {
    final class MediaRepositoryImpl: MediaNamespace.Domain.Repositories.MediaRepository {
        typealias MediaId = MediaNamespace.Domain.ValueObjects.MediaId
        
        typealias RemoteRepository = MediaNamespace.Infrastructure.Repositories.MediaRemoteRepository
        typealias LocalRepository = MediaNamespace.Infrastructure.Repositories.MediaLocalRepository
        typealias MemoryCache = MediaNamespace.Infrastructure.Cache.MediaMemoryCache
        typealias CacheStrategy = MediaNamespace.Domain.Services.MediaCacheStrategy
        
        private let remote: RemoteRepository
        private let local: LocalRepository
        private let memoryCache: MemoryCache
        private let strategy: CacheStrategy
        
        init(
            remote: RemoteRepository,
            local: LocalRepository,
            memoryCache: MemoryCache,
            strategy: CacheStrategy = .remoteFirst
        ) {
            self.remote = remote
            self.local = local
            self.memoryCache = memoryCache
            self.strategy = strategy
        }
        
        func loadMedia(by id: MediaId) async throws -> Media {
            if let cached = memoryCache.get(id) {
                return cached
            }
            
            switch strategy {
            case .remoteFirst:
                return try await loadRemoteFirst(id: id)
            case .cacheFirst:
                return try await loadCacheFirst(id: id)
            }
        }
        
        func preloadMedia(for ids: [MediaId]) async {
            for id in ids where !memoryCache.contains(id) {
                do {
                    let media = try await remote.loadMedia(by: id)
                    memoryCache.store(media)
                    try await local.save(media: media)
                } catch {
                    continue // Silent fail
                }
            }
        }
        
        // MARK: - Private Strategies
        
        private func loadRemoteFirst(id: MediaId) async throws -> Media {
            do {
                let media = try await remote.loadMedia(by: id)
                memoryCache.store(media)
                try await local.save(media: media)
                return media
            } catch {
                if let local = try? await local.loadMedia(by: id) {
                    memoryCache.store(local)
                    return local
                }
                throw error
            }
        }
        
        private func loadCacheFirst(id: MediaId) async throws -> Media {
            if let local = try? await local.loadMedia(by: id) {
                memoryCache.store(local)
                return local
            }
            
            let media = try await remote.loadMedia(by: id)
            memoryCache.store(media)
            try await local.save(media: media)
            return media
        }
    }
}
