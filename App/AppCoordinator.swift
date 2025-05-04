//
//  AppCoordinator.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 28/04/2025.
//

import UIKit

final class AppCoordinator {
    private let window: UIWindow
    private var navigationController: UINavigationController?
    private var homeCoordinator: HomeCoordinator?

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let navigationController = UINavigationController()
        self.navigationController = navigationController
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        startHomeFlow()
    }
    
    private func startHomeFlow() {
        let viewModel = HomeViewModel()
        let mapManager = MapManager(frame: UIScreen.main.bounds)

        let homeCoordinator = HomeCoordinator(
            navigationController: navigationController!,
            viewModel: viewModel,
            mapManager: mapManager
        )
        self.homeCoordinator = homeCoordinator
        homeCoordinator.start()
    }
}
