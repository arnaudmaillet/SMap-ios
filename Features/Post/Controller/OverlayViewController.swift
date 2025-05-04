//
//  OverlayViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 29/04/2025.
//

import UIKit

final class OverlayViewController: UIViewController {

    // MARK: - Subviews
    private let userView = OverlayUserView()
    private let descriptionView = OverlayDescriptionView()
    
    // MARK: - Layout

    private var appliedSafeAreaInsets: UIEdgeInsets?
    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?

    // MARK: - State
    private var post: Post.Model?
    private var isFollowing = false
    private var hasLayoutCompleted = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOverlay()
        setupFollowButtonAction()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hasLayoutCompleted = true
        applyConfigurationIfReady()
    }

    // MARK: - Configuration
    func configure(with post: Post.Model, safeAreaInsets: UIEdgeInsets) {
        self.post = post
        self.appliedSafeAreaInsets = safeAreaInsets
        applyConfigurationIfReady()
    }

    private func applyConfigurationIfReady() {
        guard hasLayoutCompleted, let post, let insets = appliedSafeAreaInsets else { return }

        userView.configure(with: post)
        userView.updateFollowButton(title: "Follow", isFollowing: false, animated: false)
        userView.applySafeAreaInsets(insets)
        

        descriptionView.configure(with: post)
        descriptionView.applySafeAreaInsets(insets)
        

        self.post = nil
        self.appliedSafeAreaInsets = nil
    }

    // MARK: - Setup
    private func setupOverlay() {
        view.backgroundColor = .clear

        [userView, descriptionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        topConstraint = userView.topAnchor.constraint(equalTo: view.topAnchor)
        bottomConstraint = descriptionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        NSLayoutConstraint.activate([
            // UserView
            topConstraint!,
            userView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            userView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // DescriptionView
            descriptionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            descriptionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint!
        ])
    }

    private func setupFollowButtonAction() {
        userView.followButton.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
    }

    @objc private func followButtonTapped() {
        isFollowing.toggle()
        let newTitle = isFollowing ? "Following" : "Follow"
        userView.updateFollowButton(title: newTitle, isFollowing: isFollowing)

        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.4,
                       options: [.curveEaseOut]) {
            self.userView.followButton.transform = .identity
        }
    }
}
