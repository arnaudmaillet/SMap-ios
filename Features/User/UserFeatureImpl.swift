//
//  UserFeatureImpl.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/10/2025.
//

extension UserNamespace {
    struct UserFeatureImpl: UserFeature {
        // MARK: - Dependencies
        let assembler: UserNamespace.DI.UserAssembler
        private let repository: UserNamespace.Domain.Repositories.UserRepository

        // MARK: - Use Cases
//        let getUserUseCase: UserNamespace.Application.UseCases.GetUserUseCase
//        let createUserUseCase: UserNamespace.Application.UseCases.CreateUserUseCase
//        let updateUserUseCase: UserNamespace.Application.UseCases.UpdateUserUseCase
//        let deleteUserUseCase: UserNamespace.Application.UseCases.DeleteUserUseCase
//
//        let getUsersUseCase: UserNamespace.Application.UseCases.GetUsersUseCase
//        let updateUsersUseCase: UserNamespace.Application.UseCases.UpdateUsersUseCase
//        let deleteUsersUseCase: UserNamespace.Application.UseCases.DeleteUsersUseCase

        // MARK: - Init
        init(environment: AppEnvironment) {
            let config = environment.dataSourceConfig
            self.assembler = DI.UserAssembler(
                environment: environment,
                dataSourceConfig: config.user
            )

            self.repository = assembler.makeRepository()

            // MARK: - Instantiate all use cases
//            self.getUserUseCase = .init(repository: repository)
//            self.getUsersUseCase = .init(repository: repository)
//            self.createUserUseCase = .init(repository: repository)
//            self.updateUserUseCase = .init(repository: repository)
//            self.deleteUserUseCase = .init(repository: repository)
//
//            self.getUsersUseCase = .init(repository: repository)
//            self.updateUsersUseCase = .init(repository: repository)
//            self.deleteUsersUseCase = .init(repository: repository)
        }
    }
}
