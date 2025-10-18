//
//  OverlayHeaderView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 20/04/2025.
//

import UIKit

final class OverlayHeaderView: UIView {

    // MARK: - Properties

    /// Subviews
    private let mainStackView = UIStackView()
    private let backButton = UIButton(type: .system)
    private let recommendationTag = UILabel()
    private let avatarImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let followerLabel = UILabel()
    private var _followButton = UIButton(type: .system)
    private let backgroundGradient = CAGradientLayer()
    
    private var topConstraint: NSLayoutConstraint?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Setup

    private func setup() {
        setupBackButton()
        setupRecommendationTag()
        setupAvatarImageView()
        setupUsernameLabel()
        setupFollowerLabel()
        setupFollowButton()
        setupBackgroundGradient()
    }

    private func setupBackButton() {
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }

    private func setupRecommendationTag() {
        recommendationTag.text = "Trending near you"
        recommendationTag.font = .preferredFont(forTextStyle: .headline)
        recommendationTag.textColor = .white
        recommendationTag.setContentHuggingPriority(.required, for: .horizontal)
        recommendationTag.setContentCompressionResistancePriority(.required, for: .horizontal)
        recommendationTag.lineBreakMode = .byTruncatingTail
        recommendationTag.numberOfLines = 1
    }

    private func setupAvatarImageView() {
        avatarImageView.layer.cornerRadius = 16
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        avatarImageView.backgroundColor = .lightGray
    }

    private func setupUsernameLabel() {
        usernameLabel.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .medium)
        usernameLabel.textColor = .white
        usernameLabel.numberOfLines = 1
        usernameLabel.lineBreakMode = .byTruncatingTail
    }

    private func setupFollowerLabel() {
        followerLabel.font = .preferredFont(forTextStyle: .caption1)
        followerLabel.textColor = .white.withAlphaComponent(0.7)
        followerLabel.numberOfLines = 1
    }

    private func setupFollowButton() {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .accent
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        config.attributedTitle = AttributedString("Follow", attributes: AttributeContainer().font(.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .medium)))
        _followButton.configuration = config
        _followButton.setContentHuggingPriority(.required, for: .horizontal)
        _followButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        _followButton.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
    }

    private func setupBackgroundGradient() {
        backgroundGradient.colors = [
            UIColor.black.withAlphaComponent(0.4).cgColor,
            UIColor.clear.cgColor
        ]
        backgroundGradient.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradient.endPoint = CGPoint(x: 0, y: 1)
        layer.insertSublayer(backgroundGradient, at: 0)
    }

    private func setupLayout() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false

        let nameStack = UIStackView(arrangedSubviews: [usernameLabel, followerLabel])
        nameStack.axis = .vertical
        nameStack.spacing = 2

        let spacer = UIView()
        
        let userInfoStack = UIStackView(arrangedSubviews: [spacer, avatarImageView, nameStack, _followButton])
        userInfoStack.axis = .horizontal
        userInfoStack.spacing = 8
        userInfoStack.alignment = .center
        
        spacer.heightAnchor.constraint(equalTo: userInfoStack.heightAnchor).isActive = true

        backButton.setContentHuggingPriority(.required, for: .horizontal)
        backButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        
        mainStackView.axis = .horizontal
        mainStackView.spacing = 8
        mainStackView.distribution = .fillProportionally

        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.addArrangedSubviews([backButton, recommendationTag, userInfoStack])
        addSubview(mainStackView)

        topConstraint = mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16)

        NSLayoutConstraint.activate([
            topConstraint!,
            mainStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),

            recommendationTag.widthAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.widthAnchor, multiplier: 0.5)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundGradient.frame = bounds
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        onAnyUserInteraction?()
    }
    
    @objc private func backButtonTapped() {
        onBackButtonTapped?()
    }
    
    @objc private func followButtonTapped() {
        onFollowTapped?()
    }
    
    @objc private func handleHeaderTapped() {
        onAnyUserInteraction?()
    }

    // MARK: - Public API
    
    var followButton: UIButton { _followButton }
    var backButtonInstance: UIButton {
        return backButton
    }
    
    var onBackButtonTapped: (() -> Void)?
    var onFollowTapped: (() -> Void)?
    var onAnyUserInteraction: (() -> Void)?

    func configure(with post: Post.Model) {
        usernameLabel.text = "Xiaobubu"
        followerLabel.text = "\(post.author.followersCount) followers"

        if let avatarURL = post.author.avatarURL {
            avatarImageView.loadImage(from: avatarURL)
        } else {
            avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
            avatarImageView.tintColor = .white.withAlphaComponent(0.5)
        }
    }

    func updateFollowButton(title: String, isFollowing: Bool, animated: Bool = true) {
        let bgColor = isFollowing ? UIColor.darkGray.withAlphaComponent(0.8) : .accent.withAlphaComponent(0.8)
        let font = UIFont.boldSystemFont(ofSize: 14)
        let attributedTitle = AttributedString(title, attributes: AttributeContainer().font(font))

        guard animated else {
            _followButton.configuration?.attributedTitle = attributedTitle
            _followButton.configuration?.baseBackgroundColor = bgColor
            return
        }

        UIView.animate(withDuration: 0.1, animations: {
            self._followButton.titleLabel?.alpha = 0
        }) { _ in
            self._followButton.configuration?.attributedTitle = attributedTitle
            self._followButton.configuration?.baseBackgroundColor = bgColor

            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: {
                self.layoutIfNeeded()
                self._followButton.titleLabel?.alpha = 1
            })
        }
    }
    
    func applySafeAreaInsets(_ insets: NSDirectionalEdgeInsets) {
        topConstraint?.constant = insets.top
    }
}
