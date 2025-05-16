//
//  OverlayReactionsViewCOntroller.swift
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
        ("flame.fill", "6.7K"),
        ("flame.fill", "6.7K"),
        ("flame.fill", "6.7K"),
        ("flame.fill", "6.7K"),
        ("flame.fill", "6.7K"),
        ("flame.fill", "6.7K")
    ]

    // MARK: - Lifecycle

    override func loadView() {
        view = overlayView
        print("OverlayReactionsViewController - loadView")
        overlayView.configure(with: reactions)
    }
}
