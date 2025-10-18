//
//  PostRemoteDataSource.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

import Foundation

e
final class PostRemoteDataSourceImpl: PostRemoteDataSource {
    private let apiClient: PostAPIClient

    init(apiClient: PostAPIClient) {
        self.apiClient = apiClient
    }

    func getPost(by id: String) async throws -> PostFeature.Domain.Entities.Post {
        let dto = try await apiClient.fetchPost(id: id)
        return PostFeature.Data.Mapper.PostMapper.toDomain(dto)
    }
}
