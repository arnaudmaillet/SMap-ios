//
//  AppInfrastructureConfig.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 18/10/2025.
//

import Foundation

struct AppDataSourceConfig {
    var post: PostNamespace.Infrastructure.DataSources.PostDataSourceConfig

    init(defaults: AppDataSourceGlobalConfig) {
        self.post = .init(config: defaults)
    }
}
