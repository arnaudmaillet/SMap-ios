//
//  HomeCoordinator.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 26/04/2025.
//

import UIKit

final class HomeCoordinator {

    // MARK: - Properties

    private(set) var window: UIWindow?
    private let navigationController: UINavigationController
    private let viewModel: HomeViewModel
    private let mapManager: MapManager
    private var feedCoordinator: FeedCoordinatorProtocol?

    // Retirer feedCoordinator d'ici, on le crée dans `start`

    // MARK: - Initialization

    init(
        navigationController: UINavigationController,
        viewModel: HomeViewModel,
        mapManager: MapManager
    ) {
        self.navigationController = navigationController
        self.viewModel = viewModel
        self.mapManager = mapManager
    }

    // MARK: - Public Methods

    /// Start the Home flow and attach it to the provided window
    func start(in window: UIWindow) {
        let homeViewController = HomeViewController(
            viewModel: viewModel,
            mapManager: mapManager
        )

        let feedCoordinator = FeedCoordinator(presentingViewController: homeViewController)
        homeViewController.setFeedCoordinator(feedCoordinator)
        self.feedCoordinator = feedCoordinator

        navigationController.setViewControllers([homeViewController], animated: false)
        self.window = window
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
