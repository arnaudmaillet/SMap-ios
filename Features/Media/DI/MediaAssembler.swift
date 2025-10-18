//
//  MediaAssembler.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

final class MediaAssembler {
    // MARK: - Typealiases
    typealias MediaId = MediaFeature.Domain.ValueObjects.MediaId
    typealias Media = MediaFeature.Domain.Entities.Media
    typealias Repository = MediaFeature.Domain.Repositories.MediaRepository
    
    typealias DefaultAPIService = MediaFeature.Infrastructure.Network.DefaultMediaAPIService
    typealias MockAPIService = MediaFeature.Infrastructure.Network.MockMediaAPIService
    typealias APIService = MediaFeature.Infrastructure.Network.MediaAPIService
    
    typealias CoreData = MediaFeature.Infrastructure.Database.MediaCoreData
    typealias MemoryCache = MediaFeature.Infrastructure.Cache.MediaMemoryCache
    typealias FileStorage = MediaFeature.Infrastructure.Cache.MediaFileStorage
    typealias CleanupScheduler = MediaFeature.Infrastructure.Cache.MediaCleanupScheduler
    
    typealias LocalRepository = MediaFeature.Infrastructure.Repositories.MediaLocalRepository
    typealias RemoteRepository = MediaFeature.Infrastructure.Repositories.MediaRemoteRepository
    typealias RepositoryImpl = MediaFeature.Infrastructure.Repositories.MediaRepositoryImpl
    typealias SourceResolverImpl = MediaFeature.Infrastructure.Services.MediaSourceResolverImpl

    typealias LoadUseCase = MediaFeature.Application.UseCases.LoadMediaUseCase
    typealias PreloadUseCase = MediaFeature.Application.UseCases.PreloadMediaUseCase

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
