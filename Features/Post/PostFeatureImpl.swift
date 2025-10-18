//
//  PostFeature.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

import Foundation

extension PostFeature {
    struct PostFeatureImpl: PostFeature {
        let assembler: DI.PostAssembler
        let getPostUseCase: PostFeature.Application.UseCases.GetPostUseCase

        init(environment: AppEnvironment) {
            let config = environment.postConfig
            self.assembler = DI.PostAssembler(environment: environment, dataSourceConfig: config)
            self.getPostUseCase = .init(repository: assembler.makeRepository())
        }
    }
}
