//
//  HomeFlow.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 03/10/2025.
//

import UIKit

final class HomeFlow {
    typealias MapViewController = MapFeature.UI.ViewController.MapViewController
    typealias MapContainer = MapFeature.Container.MapContainer
    typealias PostAnnotation = MapFeature.Domain.Model.PostAnnotation
    
    typealias FeedContainer = FeedFeature.Container.FeedContainer
    typealias ProfileContainer = ProfileFeature.Container.ProfileContainer

    typealias NavigationStackFlow = NavigationStackFeature.Flow.NavigationStackFlow
    
    private weak var navigationController: UINavigationController?
    private let mapContainer: MapContainer
    private let feedContainer: FeedContainer
    private let profileContainer: ProfileContainer
    private let navigationStackFlow: NavigationStackFeature.Flow.NavigationStackFlow
    
    init(
        navigationController: UINavigationController,
        mapContainer: MapContainer,
        feedContainer: FeedContainer,
        profileContainer: ProfileContainer,
        navigationStackFlow: NavigationStackFlow
    ) {
        self.navigationController = navigationController
        self.mapContainer = mapContainer
        self.feedContainer = feedContainer
        self.profileContainer = profileContainer
        self.navigationStackFlow = navigationStackFlow
    }
    
    @MainActor func start() {
        let homeVC = HomeViewController()
        let mapVM = mapContainer.makeMapViewModel()
        let mapVC = MapViewController(viewModel: mapVM)
        
        mapVC.onSelectAnnotation = { [weak self] annotations in
            guard let self else { return }

            Task {
                // Trouver la meilleure annotation post
                guard let best = (annotations.count == 1
                                  ? annotations.first
                                  : annotations.bestAnnotation),
                      let bestPostAnnotation = best as? PostAnnotation
                else { return }

                // 1️⃣ Préparer le FeedVC (avec données)
                let feedViewModel = try await self.feedContainer.makeFeedViewModelFromAnnotation(bestPostAnnotation, in: annotations)
                let feedVC = FeedFeature.UI.ViewController.FeedViewController(viewModel: feedViewModel)

                // 2️⃣ Créer le ProfileVC (ou tout autre VC)
                let profileViewModel = try await self.profileContainer.makeProfileViewModelFromAnnotation(bestPostAnnotation, in: annotations)
                let profileVC = ProfileFeature.UI.ViewController.ProfileViewController(viewModel: profileViewModel)

                // 3️⃣ Démarrer la stack flow avec ces VC prêts
                await MainActor.run {
                    self.navigationStackFlow.start(with: [profileVC])
                }
            }
        }
        
        homeVC.embedMap(mapVC)
        navigationController?.setViewControllers([homeVC], animated: false)
    }
}
