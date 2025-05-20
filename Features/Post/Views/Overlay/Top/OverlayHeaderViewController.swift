//
//  OverlayTopViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 14/05/2025.
//

import UIKit

final class OverlayTopViewController: UIViewController {

    // MARK: - Subviews

    private let overlayView = OverlayTopView()
    private let post: Post.Model
    private var isFollowing = false

    // MARK: - Callbacks

    var onFollowStateChanged: ((Bool) -> Void)?
    var onBackTapped: (() -> Void)?

    // MARK: - Init

    init(post: Post.Model) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
        overlayView.followButton.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = overlayView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        overlayView.configure(with: post)
//        overlayView.followButton.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
        overlayView.backButtonInstance.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
    }

    // MARK: - Public API

    func applySafeAreaInsets(_ insets: UIEdgeInsets) {
        overlayView.applySafeAreaInsets(insets)
    }

    func updateFollowState(isFollowing: Bool, animated: Bool = true) {
        self.isFollowing = isFollowing
//        let title = isFollowing ? "Following" : "Follow"
//        overlayView.updateFollowButton(title: title, isFollowing: isFollowing, animated: animated)
    }

    // MARK: - Actions

    @objc private func followButtonTapped() {
        isFollowing.toggle()
        let title = isFollowing ? "Following" : "Follow"
        overlayView.updateFollowButton(title: title, isFollowing: isFollowing)
        onFollowStateChanged?(isFollowing)

        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.4,
                       options: [.curveEaseOut]) {
            self.overlayView.followButton.transform = .identity
        }
    }
    
    @objc private func handleBackTapped() {
        onBackTapped?()
    }
}

