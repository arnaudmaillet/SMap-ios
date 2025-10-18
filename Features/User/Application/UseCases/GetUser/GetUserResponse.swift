//
//  GetUserResponse.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

extension UserFeature.Application.UseCases {
    struct GetUserResponse {
        typealias User = UserFeature.Domain.Entities.User
        let user: User
    }
}
