//
//  PostRepositoryImpl.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

extension PostNamespace.Infrastructure.Repositories {
    final class PostRepositoryImpl: PostNamespace.Domain.Repositories.PostRepository {
        typealias RemoteDataSource = PostNamespace.Infrastructure.DataSources.PostRemoteDataSource
        typealias LocalDataSource = PostNamespace.Infrastructure.DataSources.PostLocalDataSource
        typealias Post = PostNamespace.Domain.Entities.Post
        
        private let remote: RemoteDataSource
        private let local: LocalDataSource

        init(remote: RemoteDataSource, local: LocalDataSource) {
            self.remote = remote
            self.local = local
        }

        func getPost(by id: String) async throws -> Post {
            do {
                let post = try await remote.getPost(by: id)
                local.cache(post: post)
                return post
            } catch {
                if let cached = local.getCachedPost(by: id) {
                    return cached
                } else {
                    throw error
                }
            }
        }
    }
}
