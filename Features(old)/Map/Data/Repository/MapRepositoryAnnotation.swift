//
//  PostRepository.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 02/10/2025.
//

import Foundation

extension MapFeature.Data.Repository {
    protocol AnnotationRepository {
        typealias Annotation = MapFeature.Domain.Model.Annotation
        func fetchAnnotations() async throws -> [Annotation]
    }
    
    // MARK: - Mock Implementation
    
    final class RemoteAnnotationRepository: AnnotationRepository {
        typealias Annotation = MapFeature.Domain.Model.Annotation
        private let apiClient: APIClientProtocol
        
        init(apiClient: APIClientProtocol) {
            self.apiClient = apiClient
        }

        func fetchAnnotations() async throws -> [Annotation] {
            // 🔜 À implémenter plus tard (appel REST / GraphQL)
            throw NSError(
                domain: "DefaultAnnotationRepository",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "fetchAnnotations not implemented"]
            )
        }
    }
    
    final class LocalAnnotationRepository: AnnotationRepository {
        typealias Annotation = MapFeature.Domain.Model.Annotation
        typealias AnnotationMapper = MapFeature.Data.Mapper.AnnotationMapper
        
        func fetchAnnotations() async throws -> [Annotation] {
            // 🧱 1️⃣ Récupère la source unique de vérité
            let dtos = AppMockDataSource.shared.annotations
            
            // 🗺️ 2️⃣ Mappe les DTOs en objets de domaine
            return await dtos.asyncCompactMap {
                await AnnotationMapper.toDomain($0)
            }
        }
    }
}
