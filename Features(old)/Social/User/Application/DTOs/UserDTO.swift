//
//  UserDTO.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import Foundation

extension UserFeature.Application.DTOs {
    struct UserDTO: Codable {
        let id: String
        let username: String
        let avatar: String?
        let bio: String?
        let followers: Int
        let following: Int
        let postCount: Int
    }
}
