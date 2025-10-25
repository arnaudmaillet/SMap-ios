//
//  LoadMediaUseCaseImpl.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 23/10/2025.
//

import Foundation

extension MediaNamespace.Infrastructure.Cache {
    struct LoadMediaFileUseCaseImpl: LoadMediaUseCase {
        private let cacheManager: MediaCacheManager
        
        init(cacheManager: MediaCacheManager) {
            self.cacheManager = cacheManager
        }
        
        func execute(for media: Media) async throws -> Data {
            guard let url = media.cdnURL else {
                throw MediaError.invalidURL
            }
            
            if let cached = cacheManager.getCachedMedia(for: url) {
                return cached
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            cacheManager.cacheMedia(data: data, for: url)
            return data
        }
    }
}
