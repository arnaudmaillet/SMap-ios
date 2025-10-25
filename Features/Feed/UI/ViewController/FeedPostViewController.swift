//
//  FeedPostViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 08/10/2025.
//

import UIKit

extension FeedFeature.UI.ViewController {
    final class FeedPostViewController: UIViewController {
        typealias Post = PostNamespace.Domain.Entities.Post
        typealias MediaView = MediaFeature.UI.Views.MediaView

        // MARK: - Properties

        private let post: Post
        private let mediaView = MediaView()
        private let overlayView = FeedFeature.UI.View.OverlayView()
        private let safeAreaWrapper = UIView()

        // Contraintes dynamiques pour les insets
        private var topConstraint: NSLayoutConstraint?
        private var bottomConstraint: NSLayoutConstraint?
        private var leadingConstraint: NSLayoutConstraint?
        private var trailingConstraint: NSLayoutConstraint?

        private var appliedSafeAreaInsets: UIEdgeInsets = .zero

        // MARK: - Init

        init(post: Post) {
            self.post = post
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Lifecycle

        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            configure()
        }

        // MARK: - Safe Area Injection

        /// Injecte dynamiquement les insets calculés par un parent ou une transition
        func applySafeAreaInsets(_ insets: UIEdgeInsets) {
            print("✅ Injected manual insets:", insets)
            self.appliedSafeAreaInsets = insets

            // Mise à jour des contraintes dynamiques
            topConstraint?.constant = insets.top
            bottomConstraint?.constant = -(insets.bottom + 16 + 8)
            leadingConstraint?.constant = insets.left
            trailingConstraint?.constant = -(insets.right)

            // Force une mise à jour immédiate du layout
            view.layoutIfNeeded()
        }

        // MARK: - UI Setup

        private func setupUI() {
            view.backgroundColor = .black
            setupMediaView()
            setupSafeAreaWrapper()
            setupOverlayViewController()
        }

        /// Ajoute la vue média (vidéo/image plein écran)
        private func setupMediaView() {
            view.addSubview(mediaView)
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                mediaView.topAnchor.constraint(equalTo: view.topAnchor),
                mediaView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                mediaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                mediaView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }

        /// Ajoute un wrapper qui respecte les insets injectés
        private func setupSafeAreaWrapper() {
            view.addSubview(safeAreaWrapper)
            safeAreaWrapper.translatesAutoresizingMaskIntoConstraints = false
            safeAreaWrapper.backgroundColor = .clear
            safeAreaWrapper.clipsToBounds = true

            // Contraintes stockées pour pouvoir les ajuster dynamiquement
            topConstraint = safeAreaWrapper.topAnchor.constraint(equalTo: view.topAnchor)
            bottomConstraint = safeAreaWrapper.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            leadingConstraint = safeAreaWrapper.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            trailingConstraint = safeAreaWrapper.trailingAnchor.constraint(equalTo: view.trailingAnchor)

            NSLayoutConstraint.activate([
                topConstraint!,
                bottomConstraint!,
                leadingConstraint!,
                trailingConstraint!
            ])
        }

        /// Intègre OverlayViewController dans le wrapper
        private func setupOverlayViewController() {
            safeAreaWrapper.addSubview(overlayView)
            overlayView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                overlayView.topAnchor.constraint(equalTo: safeAreaWrapper.topAnchor),
                overlayView.bottomAnchor.constraint(equalTo: safeAreaWrapper.bottomAnchor),
                overlayView.leadingAnchor.constraint(equalTo: safeAreaWrapper.leadingAnchor),
                overlayView.trailingAnchor.constraint(equalTo: safeAreaWrapper.trailingAnchor)
            ])
            overlayView.isHidden = true
        }

        // MARK: - Configuration

        private func configure() {
            if let media = post.media.first {
//                mediaView.configure(with: media)
            }
        }
    }
}
