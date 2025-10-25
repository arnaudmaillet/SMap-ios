//
//  MediaRemoteDataSource.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 19/10/2025.
//

extension MediaNamespace.Infrastructure.DataSources {
    final class MediaRemoteDataSourceImpl {
        typealias MediaId = MediaNamespace.Domain.ValueObjects.MediaId
        typealias Media = MediaNamespace.Domain.Entities.Media
        typealias MediaMapper = MediaNamespace.Application.Mappers.MediaMapper
        typealias APIClient = MediaNamespace.Infrastructure.APIs.MediaAPIClient

        private let apiClient: APIClient

        init(apiClient: APIClient) {
            self.apiClient = apiClient
        }

        func getMedia(by id: MediaId) async throws -> Media {
            let dto = try await apiClient.fetchMediaDTO(by: id)
            return MediaMapper.map(dto)
        }

        func loadBatchMedia(for ids: [MediaId]) async throws -> [Media] {
            let dtos = try await apiService.fetchBatchMediaDTOs(for: ids)
            return dtos.map(MediaMapper.map)
        }
    }
}
