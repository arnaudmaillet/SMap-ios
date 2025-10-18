//
//  PostMapAnnotationMapper.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 04/10/2025.
//

import UIKit
import CoreLocation

extension MapFeature.Data.Mapper {
    struct PostAnnotationMapper {
        typealias PostAnnotationDTO = MapFeature.Data.DTO.PostAnnotationDTO
        typealias PostAnnotation = MapFeature.Domain.Model.PostAnnotation
        typealias PostThumbnailData = MapFeature.Domain.Model.PostThumbnailData
        
        static func map(_ dto: PostAnnotationDTO, coordinate: CLLocationCoordinate2D, thumbnail: UIImage?) -> PostAnnotation {
            let postData = PostThumbnailData(
                thumbnail: thumbnail,
                score: dto.score,
                authorId: UUID(uuidString: dto.authorId) ?? UUID()
            )
            return PostAnnotation(
                id: UUID(uuidString: dto.id) ?? UUID(),
                coordinate: coordinate,
                postData: postData
            )
        }
    }
}
