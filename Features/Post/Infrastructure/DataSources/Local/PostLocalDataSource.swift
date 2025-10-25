//
//  PostLocalDataSource.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

extension PostNamespace.Infrastructure.DataSources {
    protocol PostLocalDataSource {
        typealias Post = PostNamespace.Domain.Entities.Post
        func getCachedPost(by id: String) -> Post?
        func cache(post: Post)
    }
}
