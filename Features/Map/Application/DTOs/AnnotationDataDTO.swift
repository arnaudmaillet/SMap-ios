//
//  MediaPreviewAnnotationDTO.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 23/10/2025.
//

import Foundation

extension MapNamespace.Application.DTOs {
    struct AnnotationVisualDTO: Codable, Equatable {
        let id: String
        let url: String
        let type: String
        let width: Int?
        let height: Int?
        let hasAudio: Bool?
        let blurHash: String?
        let isNSFW: Bool?
    }
}
