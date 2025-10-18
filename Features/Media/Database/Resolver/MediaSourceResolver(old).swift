//
//  MediaSourceResolver.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 07/10/2025.
//

import Foundation

extension MediaFeature.Data.Resolver {
    typealias MediaSourceResolving = MediaFeature.Domain.Contract.MediaSourceResolving
    
    public struct LocalMediaSourceResolver: MediaSourceResolving {
        typealias MediaSource = MediaFeature.Domain.Model.MediaSource
        public init() {}
        
        public func resolveSource(from rawPath: String) -> MediaSource? {
            return .asset(name: rawPath)
        }
    }
    
    public struct RemoteMediaSourceResolver: MediaSourceResolving {
        typealias MediaSource = MediaFeature.Domain.Model.MediaSource
        public init() {}
        
        public func resolveSource(from rawPath: String) -> MediaSource? {
            guard let url = URL(string: "https://cdn.example.com/\(rawPath)") else {
                return nil
            }
            return .url(url)
        }
    }
}
