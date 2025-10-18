//
//  PostLocalDataSourceImpl.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

import Foundation

extension PostFeature.Infrastructure.DataSources {
    final class PostLocalDataSourceImpl: PostFeature.Infrastructure.DataSources.PostLocalDataSource {
        typealias Post = PostFeature.Domain.Entities.Post
        
        private var store: [String: Post] = [:]
        
        func getCachedPost(by id: String) -> Post? {
            return store[id]
        }
        
        func cache(post: Post) {
            store[post.id.value.uuidString] = post
        }
    }
}
