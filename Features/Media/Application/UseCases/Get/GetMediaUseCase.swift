//
//  GetMediaUseCase.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 23/10/2025.
//

extension MediaNamespace.Application.UseCases {
    protocol GetMediaUseCase {
        func execute(id: MediaNamespace.Domain.ValueObjects.MediaID) async throws -> MediaNamespace.Domain.Entities.Media?
    }
}
