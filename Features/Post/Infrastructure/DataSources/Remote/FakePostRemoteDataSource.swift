//
//  FakePostRemoteDataSource.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

import Foundation

extension PostFeature.Infrastructure.DataSources {
    final class FakePostRemoteDataSource: PostFeature.Infrastructure.DataSources.PostRemoteDataSource {
        typealias Post = PostFeature.Domain.Entities.Post
        typealias MockPostFactory = PostFeature.Infrastructure.Factories.MockPostFactory
        
        var shouldFail = false
        var delay: TimeInterval = 0
        
        func getPost(by id: String) async throws -> Post {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            if shouldFail {
                throw URLError(.notConnectedToInternet)
            }
            return MockPostFactory.makeMockPost(id: id)
        }
    }
}
