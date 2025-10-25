///
//  AppCoordinator.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 28/04/2025.
//

import UIKit

enum AppStartDestination {
    case home
    case feed(PostNamespace.Domain.Entities.Post)
//    case profile(User)
}

final class AppCoordinator {
    typealias FeedContainer = FeedFeature.Container.FeedContainer
    typealias MapContainer = MapFeature.Container.MapContainer
    typealias ProfileContainer = ProfileFeature.Container.ProfileContainer
    
    typealias FeedFlow = FeedFeature.Flow.FeedFlow
    typealias ProfileFlow = ProfileFeature.Flow.ProfileFlow
    typealias NavigationStackFlow = NavigationStackFeature.Flow.NavigationStackFlow

    // MARK: - Properties
    private let window: UIWindow
    private let navigationController: UINavigationController

    // MARK: - Containers
    private let mapContainer: MapContainer
    private let feedContainer: FeedContainer
    private let profileContainer: ProfileContainer

    // MARK: - Flows
    private lazy var homeFlow = makeHomeFlow()
    private lazy var feedFlow = makeFeedFlow()
    private lazy var profileFlow = makeProfileFlow()
    private lazy var stackFlow = makeNavigationFlow()

    // MARK: - Init
    init(window: UIWindow, env: AppEnvironment) {
        self.window = window
        self.navigationController = UINavigationController()

        // Containers
        self.mapContainer = MapContainer(env: env)
        self.feedContainer = FeedFeature.Container.FeedContainer(env: env)
        self.profileContainer = ProfileFeature.Container.ProfileContainer(env: env)

        // Pré-initialisation des mocks
        if env == .mock {
            _ = AppMockDataSource.shared
        }

        // Setup de la window
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    // MARK: - Start
    @MainActor func start(destination: AppStartDestination) {
        switch destination {
        case .home:
            homeFlow.start()

        case .feed(let post):
            // TODO: Implémenter un démarrage direct du feed si besoin
            break

//        case .profile(let user):
//            profileFlow.start(for: user)
        }
    }

    // MARK: - Flow factories
    private func makeHomeFlow() -> HomeFlow {
        return HomeFlow(
            navigationController: navigationController,
            mapContainer: mapContainer,
            feedContainer: feedContainer,
            profileContainer: profileContainer,
            navigationStackFlow: stackFlow
        )
    }
    
    private func makeNavigationFlow() -> NavigationStackFlow {
        return NavigationStackFlow(navigationController: navigationController, containers: [feedContainer])
    }

    private func makeFeedFlow() -> FeedFlow {
        return FeedFlow(
            navigationController: navigationController,
            feedContainer: feedContainer
        )
    }

    private func makeProfileFlow() -> ProfileFlow {
        return ProfileFlow(navigationController: navigationController, profileContainer: profileContainer)
    }
}

//extension AppCoordinator {
//    
//    func start() {
//        startHomeFlow()
//    }
//    
//    private func startHomeFlow() {
//        let viewModel = HomeViewModel()
//        let mapManager = MapManager(frame: UIScreen.main.bounds)
//        
//        let homeCoordinator = HomeCoordinator(
//            navigationController: navigationController,
//            viewModel: viewModel,
//            mapManager: mapManager
//        )
//        self.homeCoordinator = homeCoordinator
//        homeCoordinator.start()
//    }
//}
