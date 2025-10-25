//
//  PostRemoteDataSource.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

import Foundation

extension PostNamespace.Infrastructure.DataSources {
    protocol PostRemoteDataSource {
        typealias Post = PostNamespace.Domain.Entities.Post
        typealias PostId = PostNamespace.Domain.ValueObjects.PostId

        func getPost(by id: PostId) async throws -> Post
    }
}
