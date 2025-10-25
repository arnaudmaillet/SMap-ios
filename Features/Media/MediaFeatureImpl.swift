//
//  MediaFeatureImpl.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 23/10/2025.
//

import Foundation
import CoreData

extension MediaNamespace {
    struct MediaFeatureImpl: MediaFeature {
        // MARK: - Typealiases
        typealias GetMediaUseCase = Application.UseCases.GetMediaUseCase
        typealias GetMediaUseCaseImpl = Application.UseCases.GetMediaUseCaseImpl

        typealias GetMediasUseCase = Application.UseCases.GetMediasUseCase
        typealias GetMediasUseCaseImpl = Application.UseCases.GetMediasUseCaseImpl

        typealias CreateMediaUseCase = Application.UseCases.CreateMediaUseCase
        typealias CreateMediaUseCaseImpl = Application.UseCases.CreateMediaUseCaseImpl

        typealias UpdateMediaUseCase = Application.UseCases.UpdateMediaUseCase
        typealias UpdateMediaUseCaseImpl = Application.UseCases.UpdateMediaUseCaseImpl

        typealias DeleteMediaUseCase = Application.UseCases.DeleteMediaUseCase
        typealias DeleteMediaUseCaseImpl = Application.UseCases.DeleteMediaUseCaseImpl

        typealias CreateMediasUseCase = Application.UseCases.CreateMediasUseCase
        typealias CreateMediasUseCaseImpl = Application.UseCases.CreateMediasUseCaseImpl

        typealias UpdateMediasUseCase = Application.UseCases.UpdateMediasUseCase
        typealias UpdateMediasUseCaseImpl = Application.UseCases.UpdateMediasUseCaseImpl

        typealias DeleteMediasUseCase = Application.UseCases.DeleteMediasUseCase
        typealias DeleteMediasUseCaseImpl = Application.UseCases.DeleteMediasUseCaseImpl

        // MARK: - Use Cases
        let getMediaUseCase: GetMediaUseCase
        let getMediasUseCase: GetMediasUseCase
        let createMediaUseCase: CreateMediaUseCase
        let updateMediaUseCase: UpdateMediaUseCase
        let deleteMediaUseCase: DeleteMediaUseCase
        let createMediasUseCase: CreateMediasUseCase
        let updateMediasUseCase: UpdateMediasUseCase
        let deleteMediasUseCase: DeleteMediasUseCase

        // MARK: - Internal
        private let assembler: DI.MediaAssembler
        private let repository: Domain.Repositories.MediaRepository

        // MARK: - Init
        init(environment: AppEnvironment, container: NSPersistentContainer) {
            let config = DataSourceConfig<MediaNamespace>(
                from: environment.genericDataSourceConfig
            )

            self.assembler = DI.MediaAssembler(
                environment: environment,
                dataSourceConfig: config,
                container: container
            )

            self.repository = assembler.makeRepository()

            // MARK: UseCases
            self.getMediaUseCase = GetMediaUseCaseImpl(repository: repository)
            self.getMediasUseCase = GetMediasUseCaseImpl(repository: repository)
            self.createMediaUseCase = CreateMediaUseCaseImpl(repository: repository)
            self.updateMediaUseCase = UpdateMediaUseCaseImpl(repository: repository)
            self.deleteMediaUseCase = DeleteMediaUseCaseImpl(repository: repository)
            self.createMediasUseCase = CreateMediasUseCaseImpl(repository: repository)
            self.updateMediasUseCase = UpdateMediasUseCaseImpl(repository: repository)
            self.deleteMediasUseCase = DeleteMediasUseCaseImpl(repository: repository)
        }
    }
}
