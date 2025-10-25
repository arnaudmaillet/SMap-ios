//
//  LoadAnnotationMediaUseCase.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 24/10/2025.
//

import Foundation

extension MapNamespace.Application.UseCases {
    protocol LoadAnnotationMediaUseCase {
        func execute(for url: URL) async throws -> Data
    }
}
