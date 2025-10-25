//
//  PostFeature.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

import Foundation

extension PostNamespace {
    struct PostFeatureImpl: PostFeature {
        let assembler: PostNamespace.DI.PostAssembler
        let getPostUseCase: PostNamespace.Application.UseCases.GetPostUseCase

        init(environment: AppEnvironment) {
            let config = environment.dataSourceConfig
            self.assembler = DI.PostAssembler(
                environment: environment,
                dataSourceConfig: config.post
            )
            self.getPostUseCase = .init(repository: assembler.makeRepository())
        }
    }
}
