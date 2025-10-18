//
//  UserRepositoryImpl.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

extension UserFeature.Domain.Repository {
    final class UserRepositoryImpl: UserRepository {
        typealias UserAPIService = UserFeature.Infrastructure.Network.UserAPIService
        typealias UserMapper = UserFeature.Application.Mappers.UserMapper
        typealias User = UserFeature.Domain.Entities.User
        
        private let api: UserAPIService
        
        init(api: UserAPIService) {
            self.api = api
        }
        
        func getUser(by id: String) async throws -> User {
            let dto = try await api.fetchUser(id: id)
            return UserMapper.map(dto: dto)
        }
    }
}
