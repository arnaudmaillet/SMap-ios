//
//  MapAnnotationDTO.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 02/10/2025.
//

import Foundation

extension MapFeature.Data.DTO {
    struct AnnotationDTO: Decodable {
        let id: String
        let type: AnnotationType
        let latitude: Double
        let longitude: Double
        let payload: Data
    }

    enum AnnotationType: String, Decodable {
        case post
        // Future extensions
        // case user
        // case poi
    }
}

