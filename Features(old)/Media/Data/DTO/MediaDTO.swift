//
//  MediaDTO.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 07/10/2025.
//

import Foundation

extension MediaFeature.Data.DTO {
    struct MediaDTO: Codable {
        let id: String
        let type: String
        let path: String
    }
}
