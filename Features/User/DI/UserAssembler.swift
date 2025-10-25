//
//  UserAssembler.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

extension UserFeature.Support {
    final class UserAssembler {
        typealias UserAPIService = UserFeature.Infrastructure.Network.UserAPIService
        typealias RemoteUserAPIService = UserFeature.Infrastructure.Network.RemoteUserAPIService
        typealias LocalUserAPIService = UserFeature.Infrastructure.Network.LocalUserAPIService
        
        typealias UserRepositoryImpl = UserFeature.Domain.Repository.UserRepositoryImpl
        typealias GetUserUseCase = UserFeature.Application.UseCases.GetUserUseCase
        typealias DefaultGetUserUseCase = UserFeature.Application.UseCases.DefaultGetUserUseCase
        
        private let environment: AppEnvironment
        
        init(env: AppEnvironment) {
            self.environment = env
        }
        
        func makeGetUserUseCase() -> GetUserUseCase {
            let api: UserAPIService = switch environment {
            case .mock: LocalUserAPIService()
            case .prod, .dev: RemoteUserAPIService()
            }
            
            let repository = UserRepositoryImpl(api: api)
            return DefaultGetUserUseCase(repository: repository)
        }
    }
}
