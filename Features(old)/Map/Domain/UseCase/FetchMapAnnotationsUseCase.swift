//
//  FetchMapAnnotationsUseCase.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 02/10/2025.
//

extension MapFeature.Domain.UseCase {
    protocol FetchAnnotationsUseCase {
        typealias Annotation = MapFeature.Domain.Model.Annotation
        func execute() async throws -> [Annotation]
    }

    final class DefaultFetchAnnotationsUseCase: FetchAnnotationsUseCase {
        
        typealias Annotation = MapFeature.Domain.Model.Annotation
        typealias AnnotationRepository = MapFeature.Data.Repository.AnnotationRepository
        
        private let repository: AnnotationRepository
        
        init(repository: AnnotationRepository) {
            self.repository = repository
        }
        
        func execute() async throws -> [Annotation] {
            try await repository.fetchAnnotations()
        }
    }
}


