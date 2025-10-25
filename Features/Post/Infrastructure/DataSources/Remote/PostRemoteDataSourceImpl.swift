//
//  PostRemoteDataSourceImpl.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

import Foundation

extension PostNamespace.Infrastructure.DataSources {
    final class PostRemoteDataSourceImpl: PostRemoteDataSource, IdentifiableComponent {
        
        typealias APIClient = PostNamespace.Infrastructure.APIs.PostAPIClient
        typealias Post = PostNamespace.Domain.Entities.Post
        typealias PostId = PostNamespace.Domain.ValueObjects.PostId
        typealias PostMapper = PostNamespace.Application.Mappers.PostMapper
        typealias Config = PostNamespace.Infrastructure.DataSources.PostDataSourceConfig
        
        private typealias Err = DataSourceError<PostNamespace>
        
        private let config: Config
        private let apiClient: APIClient
        
        init(config: Config, apiClient: APIClient) {
            self.config = config
            self.apiClient = apiClient
        }
        
        func getPost(by id: PostId) async throws -> Post {
            if config.simulatedRemoteDelay > 0 {
                try await Task.sleep(nanoseconds: UInt64(config.simulatedRemoteDelay * 1_000_000_000))
            }

            if config.shouldRemoteFail {
                throw Err.network(Self.self, URLError(.networkConnectionLost))
            }

            do {
                let postIdString = id.value.uuidString
                let dto = try await apiClient.fetchPost(id: postIdString)
                return try PostMapper.toDomain(dto)
            } catch let error as URLError {
                throw Err.network(Self.self, error)
            } catch let error as MappingError {
                throw Err.mapping(Self.self, error)
            } catch {
                throw Err.unknown(Self.self, error)
            }
        }
    }
}
