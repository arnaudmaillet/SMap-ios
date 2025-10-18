//
//  UserMapper.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

extension UserFeature.Application.Mappers {
    struct UserMapper {
        typealias DTO = UserFeature.Application.DTOs.UserDTO
        typealias Entity = UserFeature.Domain.Entities.User
        typealias ValueObjects = UserFeature.Domain.ValueObjects
        
        static func map(dto: DTO) -> Entity {
            .init(
                id: .init(value: dto.id),
                username: .init(value: dto.username),
                avatar: .init(value: dto.avatar),
                bio: .init(value: dto.bio),
                followers: dto.followers,
                following: dto.following,
                postCount: dto.postCount
            )
        }
        
        static func map(entity: Entity) -> DTO {
            .init(
                id: entity.id.value,
                username: entity.username.value,
                avatar: entity.avatar.value,
                bio: entity.bio.value,
                followers: entity.followers,
                following: entity.following,
                postCount: entity.postCount
            )
        }
    }
}
