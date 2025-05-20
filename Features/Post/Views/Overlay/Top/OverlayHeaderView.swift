//
//  OverlayTopView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 20/04/2025.
//

import UIKit

final class OverlayHeaderView: UIView {
    
    private var topConstraint: NSLayoutConstraint?
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let recommendationTag: UILabel = {
        let label = UILabel()
        label.text = "Trending near you"
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 16
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iv.widthAnchor.constraint(equalToConstant: 32),
            iv.heightAnchor.constraint(equalToConstant: 32)
        ])
        return iv
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
        label.numberOfLines = 1
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
        config.attributedTitle = AttributedString("Follow", attributes: AttributeContainer().font(.boldSystemFont(ofSize: 14)))
        
        let button = UIButton(configuration: config)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()
    
    private let backgroundGradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.black.withAlphaComponent(0.4).cgColor,
            UIColor.clear.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        return gradient
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundGradient.frame = bounds
    }
    
    private func setup() {
        layer.insertSublayer(backgroundGradient, at: 0)
        layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
        
        let nameStack = UIStackView(arrangedSubviews: [usernameLabel, followerLabel])
        nameStack.axis = .vertical
        nameStack.spacing = 2
        
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let userInfoStack = UIStackView(arrangedSubviews: [spacer, avatarImageView, nameStack, followButton])
        userInfoStack.axis = .horizontal
        userInfoStack.spacing = 8
        userInfoStack.alignment = .center
        
        backButton.setContentHuggingPriority(.required, for: .horizontal)
        backButton.setContentCompressionResistancePriority(.required, for: .horizontal)


        let mainStack = UIStackView(arrangedSubviews: [backButton, recommendationTag, userInfoStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 8
        mainStack.distribution = .fillProportionally
        
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)
        
        topConstraint = mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 16)
        
        NSLayoutConstraint.activate([
            topConstraint!,
            mainStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            
            recommendationTag.widthAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.widthAnchor, multiplier: 0.5)
        ])
    }
    
    func applySafeAreaInsets(_ insets: UIEdgeInsets) {
        topConstraint?.constant = insets.top
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
    
    func updateFollowButton(title: String, isFollowing: Bool, animated: Bool = true) {
        let bgColor = isFollowing ? UIColor.darkGray.withAlphaComponent(0.8) : .accent.withAlphaComponent(0.8)
        let font = UIFont.boldSystemFont(ofSize: 14)
        let attributedTitle = AttributedString(title, attributes: AttributeContainer().font(font))
        
        print("test")

        guard animated else {
            followButton.configuration?.attributedTitle = attributedTitle
            followButton.configuration?.baseBackgroundColor = bgColor
            return
        }

        // Étape 1 : fade out
        UIView.animate(withDuration: 0.1, animations: {
            self.followButton.titleLabel?.alpha = 0
        }) { _ in
            // Étape 2 : update config (cela modifie le intrinsicContentSize du bouton)
            self.followButton.configuration?.attributedTitle = attributedTitle
            self.followButton.configuration?.baseBackgroundColor = bgColor

            // Étape 3 : layout + fade in
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: {
                self.layoutIfNeeded() // Pour animer la taille du bouton
                self.followButton.titleLabel?.alpha = 1
            })
        }
    }
    
    
    var backButtonInstance: UIButton {
        return backButton
    }
}
