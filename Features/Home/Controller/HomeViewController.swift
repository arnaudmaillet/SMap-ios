//
//  HomeViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 08/04/2025.
//

import UIKit
import SwiftUI
import MapKit

final class HomeViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: HomeViewModel
    private let mapManager: MapManager
    private weak var feedCoordinator: FeedCoordinatorProtocol?
    private var lastSelectedAnnotation: MKAnnotation?
    private(set) var posts: [Post.Model]
    
    private var isInteractionAllowed = true
    private var isMapMoving = false
    private var allowInteractionTimer: Timer?
    private(set) var contentView = UIView()
    
    var canInteract: Bool {
        return isInteractionAllowed
    }

    // MARK: - Initialization

    init(viewModel: HomeViewModel, mapManager: MapManager) {
        self.viewModel = viewModel
        self.mapManager = mapManager
        self.posts = []
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setFeedCoordinator(_ coordinator: FeedCoordinatorProtocol) {
        self.feedCoordinator = coordinator
    }

    // MARK: - Setup
    private func setupMap() {
        mapManager.attachMapView(to: contentView)
    }

    @MainActor
    private func loadPosts() {
        posts = []
        _ = viewModel.loadMockPosts(
            onPostReady: { [weak self] post in
                guard let self else { return }
                let annotation = Post.Annotation.Model(post: post)
                self.mapManager.addAnnotations([annotation])
                self.posts.append(post)
            }
        )
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        setupMap()
        mapManager.delegate = self
        loadPosts()
    }

    // MARK: - Annotation Handling

    func hideSelectedAnnotation() {
        guard let selected = mapManager.selectedAnnotations.first else { return }
        mapManager.deselectAnnotations([selected], animated: false)
        if let view = mapManager.view(for: selected) {
            view.isHidden = true
        }
    }

    func resetLastSelectedAnnotation() {
        lastSelectedAnnotation = nil
    }

    func refreshLastSelectedAnnotation() {
        guard let annotation = lastSelectedAnnotation else { return }
        mapManager.refreshAnnotations([annotation])
    }

    func setLastSelectedAnnotation(_ annotation: MKAnnotation?) {
        lastSelectedAnnotation = annotation
    }
    
    // MARK: - Public API

    func showFeed(for posts: [Post.Model], from annotationView: MKAnnotationView, image: UIImage) {
        
        guard isInteractionAllowed else {
            return
        }
        
        setLastSelectedAnnotation(annotationView.annotation)
        mapManager.setInteractionEnabled(false)
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut]) {
            self.contentView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
        feedCoordinator?.presentFeed(for: posts, from: annotationView, in: mapManager.provideMapView(), image: image)
    }
    
    func setMapInteractionEnabled(_ isEnabled: Bool) {
        mapManager.setInteractionEnabled(isEnabled)
    }
    
    func lockInteraction() {
        allowInteractionTimer?.invalidate()
        isInteractionAllowed = false
        isMapMoving = true
    }

    func unlockInteraction(after delay: TimeInterval = 0) {
        allowInteractionTimer?.invalidate()
        allowInteractionTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.isInteractionAllowed = true
            self?.isMapMoving = false
        }
    }
    
    func currentAnnotationFrameInWindow() -> CGRect? {
        guard let annotation = lastSelectedAnnotation,
              let annotationView = mapManager.view(for: annotation) else {
            return nil
        }
        return annotationView.convert(annotationView.bounds, to: view.window)
    }
}
