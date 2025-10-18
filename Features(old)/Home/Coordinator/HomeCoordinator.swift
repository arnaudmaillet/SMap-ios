//
//  HomeCoordinator.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 26/04/2025.
//

import UIKit
import MapKit // ✅ pour MKAnnotationView

enum HomeStartMode {
    case map
    case feed
}

final class HomeCoordinator {
    private let navigationController: UINavigationController
    private let viewModel: HomeViewModel
    private let mapManager: MapManager
    private var feedContainerCoordinator: FeedCoordinatorDelegate?

    init(navigationController: UINavigationController,
         viewModel: HomeViewModel,
         mapManager: MapManager) {
        self.navigationController = navigationController
        self.viewModel = viewModel
        self.mapManager = mapManager
    }

    func start() {
        showHome(startMode: .map) // .map par défaut, .feed pour bypass
    }

    private func showHome(startMode: HomeStartMode = .map) {
        let homeVC = HomeVC(viewModel: viewModel, mapManager: mapManager)
        let feedContainerCoordinator = FeedContainerCoordinator(rootVC: homeVC)
        self.feedContainerCoordinator = feedContainerCoordinator
        homeVC.setFeedContainerCoordinator(feedContainerCoordinator)

        navigationController.setViewControllers([homeVC], animated: false)
        navigationController.isNavigationBarHidden = true

        if startMode == .feed {
            let posts = viewModel.loadMockPostsSync(offline: true)
            homeVC.launchFeedDirectly(with: posts)
        }
    }
}
