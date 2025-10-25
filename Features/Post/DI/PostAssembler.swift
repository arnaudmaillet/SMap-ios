//
//  PostAssembler.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/10/2025.
//

import Foundation

extension PostNamespace.DI {
    struct PostAssembler {
        typealias GetUseCase = PostNamespace.Application.UseCases.GetPostUseCase
        typealias Repository = PostNamespace.Domain.Repositories.PostRepository
        
        
        typealias DataSourceConfig = PostNamespace.Infrastructure.DataSources.PostDataSourceConfig
        typealias RepositoryImpl = PostNamespace.Infrastructure.Repositories.PostRepositoryImpl
        
        typealias FakeRemoteDataSource = PostNamespace.Infrastructure.DataSources.FakePostRemoteDataSource
        typealias RemoteDataSource = PostNamespace.Infrastructure.DataSources.PostRemoteDataSource
        typealias RemoteDataSourceImpl = PostNamespace.Infrastructure.DataSources.PostRemoteDataSourceImpl
        
        typealias FakeLocalDataSource = PostNamespace.Infrastructure.DataSources.FakePostLocalDataSource
        typealias LocalDataSource = PostNamespace.Infrastructure.DataSources.PostLocalDataSource
        typealias LocalDataSourceImpl = PostNamespace.Infrastructure.DataSources.PostLocalDataSourceImpl
        
        typealias APIClient = PostNamespace.Infrastructure.APIs.PostAPIClient
        typealias APIClientImpl = PostNamespace.Infrastructure.APIs.PostAPIClientImpl
        
        
        let environment: AppEnvironment
        let dataSourceConfig: DataSourceConfig
        
        init(
            environment: AppEnvironment,
            dataSourceConfig: DataSourceConfig
        ) {
            self.environment = environment
            self.dataSourceConfig = dataSourceConfig
        }
        
        func makeRepository() -> Repository {
            return RepositoryImpl(
                remote: makeRemoteDataSource(),
                local: makeLocalDataSource()
            )
        }
        
        private func makeRemoteDataSource() -> RemoteDataSource {
            if environment == .mock {
                return FakeRemoteDataSource(config: dataSourceConfig)
            } else {
                return RemoteDataSourceImpl(config: dataSourceConfig, apiClient: makeApiClient())
            }
        }
        
        private func makeLocalDataSource() -> LocalDataSource {
            if environment == .mock {
                return FakeLocalDataSource()
            }else {
                return LocalDataSourceImpl()
            }
        }
        
        private func makeApiClient() -> APIClient {
            return APIClientImpl()
        }
    }
}
