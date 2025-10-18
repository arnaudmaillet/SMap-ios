//
//  PostMapAnnotationDTO.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 04/10/2025.
//

extension MapFeature.Data.DTO {
    struct PostAnnotationDTO: Codable {
        let id: String
        let authorId: String
        let score: Int
        let thumbnailRef: ThumbnailReference?
    }
}
