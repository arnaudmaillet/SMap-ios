//
//  OverlayBottomViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 10/05/2025.
//

import UIKit

final class OverlayBottomViewController: UIViewController {

    private let overlayView = OverlayBottomView()
    private var post: Post.Model?

    // MARK: - Init

    init(post: Post.Model) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        self.view = overlayView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let post = post {
            overlayView.configure(with: post)
        }
    }

    // MARK: - Public

    func configure(with post: Post.Model, safeAreaInsets: UIEdgeInsets) {
        self.post = post
        overlayView.configure(with: post)
        overlayView.applySafeAreaInsets(safeAreaInsets)
    }

    func applySafeAreaInsets(_ insets: UIEdgeInsets) {
        overlayView.applySafeAreaInsets(insets)
    }
}
