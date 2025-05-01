//
//  HomeViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 08/04/2025.
//

import UIKit
import SwiftUI
import MapKit

class HomeViewController: UIViewController {
    
    private let viewModel = HomeViewModel()
    private let tabBarViewModel = TabBarViewModel()
    private var tabBarHost: UIHostingController<AnyView>!
    private let locationPermissionManager = LocationPermissionManager()
    
    var mapManager: MapManager!
    var lastSelectedAnnotation: MKAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        locationPermissionManager.requestPermission()
        setupMapView()
    }
    
    private func setupMapView() {
        let posts = MockPostProvider.generateMockPosts(count: 4)
        self.viewModel.posts = posts
        
        self.mapManager = MapManager(frame: self.view.bounds, posts: posts, delegate: self)
        self.view.addSubview(self.mapManager.mapView)
        
        self.mapManager.mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.mapManager.mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.mapManager.mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.mapManager.mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.mapManager.mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func setupTabBar() {
        let tabBar = MainTabBar().environmentObject(tabBarViewModel)
        tabBarHost = UIHostingController(rootView: AnyView(tabBar))
        
        addChild(tabBarHost)
        view.addSubview(tabBarHost.view)
        tabBarHost.didMove(toParent: self)
        tabBarHost.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tabBarHost.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarHost.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarHost.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBarHost.view.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func presentFeed(for renderable: PostRenderable, from annotationView: MKAnnotationView, image: UIImage) {
        guard let mapView = mapManager?.mapView else { return }

        if let annotation = annotationView.annotation {
            lastSelectedAnnotation = annotation
            if let view = mapView.view(for: annotation) {
                view.isHidden = true
            }
        }

        let feedVC = FeedViewController(imageURL: renderable.thumbnailURL)
        feedVC.originFrame = annotationView.convert(annotationView.bounds, to: self.view)
        feedVC.delegate = self
        feedVC.modalPresentationStyle = .custom

        let transitionImage = TransitionImageHelper.getTransitionImage(from: annotationView) ?? image

        let transitionDelegate = NavigationTransitionDelegate(
            originFrame: feedVC.originFrame,
            image: transitionImage
        )
        feedVC.transitioningDelegate = transitionDelegate

        present(feedVC, animated: true)
    }
}
