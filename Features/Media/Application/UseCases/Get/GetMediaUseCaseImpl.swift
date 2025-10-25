//
//  GetMediaUseCaseImpl.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 23/10/2025.
//

extension MediaNamespace.Application.UseCases {
    struct GetMediaUseCaseImpl: GetMediaUseCase {
        private let repository: MediaNamespace.Domain.Repositories.MediaRepository

        init(repository: MediaNamespace.Domain.Repositories.MediaRepository) {
            self.repository = repository
        }

        func execute(id: MediaNamespace.Domain.ValueObjects.MediaID) async throws -> MediaNamespace.Domain.Entities.Media? {
            try await repository.fetch(by: id)
        }
    }
}
