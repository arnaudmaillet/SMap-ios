//
//  MediaAssembler.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

extension MediaNamespace.DI {
    final class MediaAssembler {
        // MARK: - Typealiases
        typealias MediaId = MediaNamespace.Domain.ValueObjects.MediaId
        typealias Media = MediaNamespace.Domain.Entities.Media
        typealias Repository = MediaNamespace.Domain.Repositories.MediaRepository
        
        typealias DefaultAPIService = MediaNamespace.Infrastructure.APIs.DefaultMediaAPIService
        typealias MockAPIService = MediaNamespace.Infrastructure.APIs.MockMediaAPIService
        typealias APIService = MediaNamespace.Infrastructure.APIs.MediaAPIService
        
        typealias CoreData = MediaNamespace.Infrastructure.Database.MediaCoreData
        typealias MemoryCache = MediaNamespace.Infrastructure.Cache.MediaMemoryCache
        typealias FileStorage = MediaNamespace.Infrastructure.Cache.MediaFileStorage
        typealias CleanupScheduler = MediaNamespace.Infrastructure.Cache.MediaCleanupScheduler
        
        typealias LocalRepository = MediaNamespace.Infrastructure.Repositories.MediaLocalRepository
        typealias RemoteRepository = MediaNamespace.Infrastructure.Repositories.MediaRemoteRepository
        typealias RepositoryImpl = MediaNamespace.Infrastructure.Repositories.MediaRepositoryImpl
        typealias SourceResolverImpl = MediaNamespace.Infrastructure.Services.MediaSourceResolverImpl
        
        typealias LoadUseCase = MediaNamespace.Application.UseCases.LoadMediaUseCase
        typealias PreloadUseCase = MediaNamespace.Application.UseCases.PreloadMediaUseCase
        
        // MARK: - Properties
        
        private let environment: AppEnvironment
        private let memoryCache: MemoryCache
        private let coreData: CoreData
        private let fileStorage: FileStorage
        private let cleanupScheduler: CleanupScheduler
        
        // MARK: - Init
        
        init(environment: AppEnvironment) {
            self.environment = environment
            self.memoryCache = .init()
            self.coreData = .init()
            self.fileStorage = .init()
            self.cleanupScheduler = .init(
                fileStorage: fileStorage,
                coreData: coreData
            )
        }
        
        func makeRemoteRepository() -> RemoteRepository {
            let apiService: APIService = {
                switch environment {
                case .mock:
                    return MockAPIService()
                case .dev, .prod:
                    return DefaultAPIService(environment: environment)
                }
            }()
            
            return RemoteRepository(apiService: apiService)
        }
        
        func makeLocalRepository() -> LocalRepository {
            .init(context: coreData.context, fileStorage: fileStorage)
        }
        
        func makeRepository() -> RepositoryImpl {
            .init(
                remote: makeRemoteRepository(),
                local: makeLocalRepository(),
                memoryCache: memoryCache,
                strategy: environment == .prod ? .remoteFirst : .cacheFirst
            )
        }
        
        func makeLoadUseCase() -> LoadUseCase {
            .init(repository: makeRepository())
        }
        
        func makePreloadUseCase() -> PreloadUseCase {
            .init(repository: makeRepository())
        }
        
        func makeSourceResolver() -> SourceResolverImpl {
            .init()
        }
        
        func startCleanupIfNeeded() {
            cleanupScheduler.startCleanup()
        }
    }
}
