//
//  OverlayViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 29/04/2025.
//

import UIKit

final class OverlayViewController: UIViewController {

    private let overlayUserView = OverlayUserView()
    private var isFollowing = false
    private var topConstraint: NSLayoutConstraint?
    private var topInset: CGFloat = 8

    override func viewDidLoad() {
        super.viewDidLoad()
        setupOverlayView()
        setupFollowButtonAction()
    }
    

    private func setupOverlayView() {
        view.backgroundColor = .blue.withAlphaComponent(0.5)

        overlayUserView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayUserView)

        overlayUserView.setContentHuggingPriority(.required, for: .vertical)
        overlayUserView.setContentCompressionResistancePriority(.required, for: .vertical)

        topConstraint = overlayUserView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topInset)

        NSLayoutConstraint.activate([
            topConstraint!,
            overlayUserView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayUserView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupFollowButtonAction() {
        overlayUserView.followButton.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
    }

    func configure(with post: Post.Model, safeAreaInsets: UIEdgeInsets) {
        topConstraint?.constant = safeAreaInsets.top + topInset
        overlayUserView.configure(with: post)
        overlayUserView.updateFollowButton(title: "Follow", isFollowing: false, animated: false)
    }

    @objc private func followButtonTapped() {
        isFollowing.toggle()
        
        let newTitle = isFollowing ? "Following" : "Follow"
        overlayUserView.updateFollowButton(title: newTitle, isFollowing: isFollowing)

        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.4,
                       options: [.curveEaseOut],
                       animations: {
            self.overlayUserView.followButton.transform = .identity
        })
    }
}
