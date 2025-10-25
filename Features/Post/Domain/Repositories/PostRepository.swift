//
//  PostRepository.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

extension PostNamespace.Domain.Repositories {
    protocol PostRepository {
        typealias Post = PostNamespace.Domain.Entities.Post
        typealias PostID = PostNamespace.Domain.ValueObjects.PostID
        
        func fetch(by id: PostID) async throws -> PostNamespace.Domain.Entities.Post
        func create(with post: Post) async throws -> Post
        func update(by id: PostID, with post: Post) async throws -> Post
        func delete(by id: PostID) async throws
        
        func batchFetch(by ids: [PostID]) async throws -> [Post]
        func batchUpdate(with posts: [Post]) async throws -> [Post]
        func batchDelete(by ids: [PostID]) async throws
    }
}
