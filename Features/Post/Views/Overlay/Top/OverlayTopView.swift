//
//  OverlayTopView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 20/04/2025.
//

import UIKit

final class OverlayTopView: UIView {

    // MARK: - Subviews

    private let recommendationTag: UILabel = {
        let label = UILabel()
        label.text = "Trending near you"
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 32),
            imageView.heightAnchor.constraint(equalToConstant: 32)
        ])
        return imageView
    }()

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let followerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .white.withAlphaComponent(0.7)
        return label
    }()

    private(set) var followButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .accent
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        config.attributedTitle = AttributedString("Follow", attributes: AttributeContainer().font(.boldSystemFont(ofSize: 12)))

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()

    // MARK: - Layout

    private let stackView = UIStackView()
    private let verticalStack = UIStackView()
    private let topSpacer = UIView()
    private let rightStackContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.clipsToBounds = true
        return view
    }()

    private var topSpacerHeightConstraint: NSLayoutConstraint?
    private var rightStackWidthConstraint: NSLayoutConstraint?

    // MARK: - Gradient

    private let backgroundGradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.black.withAlphaComponent(0.8).cgColor,
            UIColor.clear.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        return gradient
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundGradient.frame = bounds
    }

    // MARK: - Setup

    private func setupView() {
        layer.insertSublayer(backgroundGradient, at: 0)

        followButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 70).isActive = true
        followButton.addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        followButton.addTarget(self, action: #selector(handleTouchUp), for: [.touchUpInside, .touchCancel, .touchDragExit])

        // Text stack (username + follower count)
        let textStack = UIStackView(arrangedSubviews: [usernameLabel, followerLabel])
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 2

        // User info (avatar + text)
        let userInfoStack = UIStackView(arrangedSubviews: [avatarImageView, textStack])
        userInfoStack.axis = .horizontal
        userInfoStack.spacing = 8
        userInfoStack.alignment = .center
        userInfoStack.translatesAutoresizingMaskIntoConstraints = false
        userInfoStack.widthAnchor.constraint(greaterThanOrEqualToConstant: 96).isActive = true

        // Right stack (user info + follow button)
        let rightStack = UIStackView(arrangedSubviews: [userInfoStack, followButton])
        rightStack.axis = .horizontal
        rightStack.spacing = 12
        rightStack.alignment = .center
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        rightStack.setContentHuggingPriority(.required, for: .horizontal)
        rightStack.setContentCompressionResistancePriority(.required, for: .horizontal)

        // Container view with background and padding
        rightStackContainer.translatesAutoresizingMaskIntoConstraints = false
        rightStackContainer.clipsToBounds = true
        rightStackContainer.addSubview(rightStack)

        NSLayoutConstraint.activate([
            rightStack.topAnchor.constraint(equalTo: rightStackContainer.topAnchor),
            rightStack.bottomAnchor.constraint(equalTo: rightStackContainer.bottomAnchor),
            rightStack.leadingAnchor.constraint(equalTo: rightStackContainer.leadingAnchor),
            rightStack.trailingAnchor.constraint(equalTo: rightStackContainer.trailingAnchor)
        ])

        // Main stack (recommendation label + container)
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(recommendationTag)
        stackView.addArrangedSubview(rightStackContainer)

        // Top spacer
        topSpacer.translatesAutoresizingMaskIntoConstraints = false
        topSpacerHeightConstraint = topSpacer.heightAnchor.constraint(equalToConstant: 0)
        topSpacerHeightConstraint?.isActive = true

        // Vertical container
        verticalStack.axis = .vertical
        verticalStack.spacing = 12
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.addArrangedSubview(topSpacer)
        verticalStack.addArrangedSubview(stackView)

        addSubview(verticalStack)

        // Constraints
        rightStackWidthConstraint = rightStackContainer.widthAnchor.constraint(lessThanOrEqualTo: verticalStack.widthAnchor, multiplier: 0.75)
        rightStackWidthConstraint?.priority = .defaultLow
        rightStackWidthConstraint?.isActive = true

        NSLayoutConstraint.activate([
            verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            verticalStack.topAnchor.constraint(equalTo: topAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    // MARK: - Public API

    func configure(with post: Post.Model) {
        usernameLabel.text = "Xiaobubu"
        followerLabel.text = "\(post.author.followers.count) followers"

        if let avatarURL = post.author.avatarURL {
            avatarImageView.loadImage(from: avatarURL)
        } else {
            avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
            avatarImageView.tintColor = .white.withAlphaComponent(0.5)
        }
    }

    func applySafeAreaInsets(_ insets: UIEdgeInsets) {
        topSpacerHeightConstraint?.constant = insets.top
    }

    func updateFollowButton(title: String, isFollowing: Bool, animated: Bool = true) {
        let bgColor = isFollowing ? UIColor.darkGray.withAlphaComponent(0.8) : .accent.withAlphaComponent(0.8)
        let font = UIFont.systemFont(ofSize: 14)
        let attributedTitle = AttributedString(title, attributes: AttributeContainer().font(font))

        guard animated else {
            followButton.configuration?.attributedTitle = attributedTitle
            followButton.configuration?.baseBackgroundColor = bgColor
            return
        }

        // Étape 1 : fade out
        UIView.animate(withDuration: 0.1, animations: {
            self.followButton.titleLabel?.alpha = 0
        }) { _ in
            // Étape 2 : mise à jour config (modifie intrinsic size)
            self.followButton.configuration?.attributedTitle = attributedTitle
            self.followButton.configuration?.baseBackgroundColor = bgColor

            // Étape 3 : animate layout (changement de taille fluide)
            UIViewPropertyAnimator(duration: 0.25, dampingRatio: 0.85) {
                self.stackView.layoutIfNeeded()
            }.startAnimation()

            // Étape 4 : fade in du nouveau texte pendant resize
            UIView.animate(withDuration: 0.2, delay: 0.05, options: [.curveEaseInOut], animations: {
                self.followButton.titleLabel?.alpha = 1
            })
        }
    }

    // MARK: - Animations

    @objc private func handleTouchDown() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut]) {
            self.followButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func handleTouchUp() {
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.4,
                       options: [.curveEaseOut]) {
            self.followButton.transform = .identity
        }
    }
}
