//
//  FakePostLocalDataSource.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

import Foundation

extension PostNamespace.Infrastructure.DataSources {
    final class FakePostLocalDataSource: PostNamespace.Infrastructure.DataSources.PostLocalDataSource {
        typealias Post = PostNamespace.Domain.Entities.Post
        
        private var store: [String: Post] = [:]

        func getCachedPost(by id: String) -> Post? {
            store[id]
        }

        func cache(post: Post) {
            store[post.id.value.uuidString] = post
        }
    }
}
