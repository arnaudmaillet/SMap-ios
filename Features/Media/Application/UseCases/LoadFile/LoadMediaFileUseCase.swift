//
//  LoadMediaUseCase.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import Foundation

extension MediaNamespace.Application.UseCases {
    protocol LoadMediaFileUseCase {
        typealias Media = MediaNamespace.Domain.Entities.Media
        
        func execute(for media: Media) async throws -> Data
    }
}
