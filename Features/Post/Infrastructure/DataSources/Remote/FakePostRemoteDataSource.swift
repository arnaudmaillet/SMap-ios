//
//  FakePostRemoteDataSource.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

import Foundation

extension PostNamespace.Infrastructure.DataSources {
    final class FakePostRemoteDataSource: PostNamespace.Infrastructure.DataSources.PostRemoteDataSource {
        typealias Post = PostNamespace.Domain.Entities.Post
        typealias MockPostFactory = PostNamespace.Infrastructure.Factories.MockPostFactory
        typealias Config = PostNamespace.Infrastructure.DataSources.PostDataSourceConfig
    
        private let config: Config

        init(config: Config) {
            self.config = config
        }
        
        func getPost(by id: String) async throws -> Post {
            if config.simulatedRemoteDelay > 0 {
                try await Task.sleep(nanoseconds: UInt64(config.simulatedRemoteDelay * 1_000_000_000))
            }

            if config.shouldRemoteFail {
                throw NSError(domain: "Fake error", code: -1)
            }
            
            return MockPostFactory.makeMockPost(id: id)
        }
    }
}
