//
//  UserEntity.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

extension UserFeature.Domain.Entities {
    struct User: Identifiable, Equatable {
        typealias ValueObjects = UserFeature.Domain.ValueObjects
        let id: ValueObjects.UserID
        let username: ValueObjects.Username
        let avatar: ValueObjects.AvatarURL
        let bio: ValueObjects.Bio
        let followers: Int
        let following: Int
        let postCount: Int
    }
}
