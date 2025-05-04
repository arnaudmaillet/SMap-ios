//
//  HomeCoordinator.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 26/04/2025.
//

import UIKit

final class HomeCoordinator {
    private let navigationController: UINavigationController
    private let viewModel: HomeViewModel
    private let mapManager: MapManager
    private var feedCoordinator: FeedCoordinatorProtocol?

    init(navigationController: UINavigationController,
         viewModel: HomeViewModel,
         mapManager: MapManager) {
        self.navigationController = navigationController
        self.viewModel = viewModel
        self.mapManager = mapManager
    }
    
    func start() {
        showHome()
    }
    
    private func showHome() {
        let homeVC = HomeViewController(viewModel: viewModel, mapManager: mapManager)
        let feedCoordinator = FeedCoordinator(presentingViewController: homeVC)
        self.feedCoordinator = feedCoordinator
        homeVC.setFeedCoordinator(feedCoordinator)
        
        navigationController.setViewControllers([homeVC], animated: false)
    }
}
