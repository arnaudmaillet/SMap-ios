//
//  PostInfrastructureConfig.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

import Foundation

extension PostFeature.Infrastructure.DataSources {
    struct PostDataSourceConfig {
        typealias Post = PostFeature.Domain.Entities.Post
        
        var shouldRemoteFail: Bool = false
        var simulatedRemoteDelay: TimeInterval = 0
        var preloadedCache: [String: Post] = [:]
    }
}
