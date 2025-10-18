//
//  MapAnnotationMapper.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 02/10/2025.
//

import UIKit
import CoreLocation

extension MapFeature.Data.Mapper {
    protocol AnnotationMapping {
        typealias AnnotationDTO = MapFeature.Data.DTO.AnnotationDTO
        typealias Annotation = MapFeature.Domain.Model.Annotation
        
        static func toDomain(_ dto: AnnotationDTO) async -> Annotation?
    }
    
    struct AnnotationMapper: AnnotationMapping {
        typealias AnnotationDTO = MapFeature.Data.DTO.AnnotationDTO
        typealias PostAnnotationDTO = MapFeature.Data.DTO.PostAnnotationDTO
        typealias Annotation = MapFeature.Domain.Model.Annotation
        typealias PostAnnotation = MapFeature.Domain.Model.PostAnnotation
        typealias PostThumbnailData = MapFeature.Domain.Model.PostThumbnailData
        
        static func toDomain(_ dto: AnnotationDTO) async -> Annotation? {
            let coordinate = CLLocationCoordinate2D(
                latitude: dto.latitude,
                longitude: dto.longitude
            )

            switch dto.type {
            case .post:
                guard let postAnnotationDTO = try? JSONDecoder().decode(PostAnnotationDTO.self, from: dto.payload) else {
                    print("⚠️ Erreur : impossible de décoder PostDTO pour \(dto.id)")
                    return nil
                }

                let thumbnail = await ThumbnailLoader.loadImage(from: postAnnotationDTO.thumbnailRef)
                let postData = PostThumbnailData(
                    thumbnail: thumbnail,
                    score: postAnnotationDTO.score,
                    authorId: UUID(uuidString: postAnnotationDTO.authorId) ?? UUID()
                )

                guard let postId = UUID(uuidString: postAnnotationDTO.id) else {
                    print("❌ ID de post invalide : \(postAnnotationDTO.id)")
                    return nil
                }
                
                let annotationId = UUID.namespaced(from: postId, namespace: IDNamespace.post)

                return PostAnnotation(
                    id: annotationId,
                    coordinate: coordinate,
                    postData: postData
                )
                
            // ✅ futur-ready : autres cas ajoutables facilement
            // case .user:
            //     let userDTO = try? JSONDecoder().decode(Map.Data.DTO.UserDTO.self, from: dto.payload)
            //     ...
            // case .poi:
            //     let poiDTO = try? JSONDecoder().decode(Map.Data.DTO.POIDTO.self, from: dto.payload)
            //     ...

            }
        }
    }
}
