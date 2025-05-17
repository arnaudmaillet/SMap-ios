//
//  OverlayReactionsViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 05/05/2025.
//

import UIKit

final class OverlayReactionsViewController: UIViewController {

    // MARK: - UI

    private let addButton = UIButton(type: .system)
    private let overlayView = OverlayReactionsView()

    private let reactions: [(String, String)] = [
        ("heart.fill", "123K"),
        ("face.smiling.inverse", "12.3K"),
        ("hand.thumbsup.fill", "8.9K"),
        ("flame.fill", "6.4K"),
        ("star.fill", "63.7K"),
        ("moon.stars.fill", "4.5K"),
        ("paperplane.fill", "7.6K"),
        ("playstation.logo", "9.7K"),
        ("apple.image.playground", "67.1K")
    ]

    // MARK: - Lifecycle

    override func loadView() {
        view = overlayView
        overlayView.configure(with: reactions)
        overlayView.applySafeAreaInsets(view.safeAreaInsets)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Public API

    func applySafeAreaInsets(_ insets: UIEdgeInsets) {
        overlayView.applySafeAreaInsets(insets)
    }
}
