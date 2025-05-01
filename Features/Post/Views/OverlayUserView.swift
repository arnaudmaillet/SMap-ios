//
//  UserOverlayView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 20/04/2025.
//

import UIKit

final class UserOverlayView: UIView {

    let avatarImageView = UIImageView()
    let usernameLabel = UILabel()
    let followerLabel = UILabel()
    let followButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Follow"
        configuration.baseBackgroundColor = .systemPurple
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        return button
    }()

    private let stackView = UIStackView()
    private let padding: CGFloat = 16

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setup() {
        backgroundColor = .red.withAlphaComponent(0.5)

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.backgroundColor = .lightGray
        avatarImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        usernameLabel.font = .boldSystemFont(ofSize: 16)
        usernameLabel.textColor = .white
        usernameLabel.textAlignment = .left

        followerLabel.font = .systemFont(ofSize: 12)
        followerLabel.textColor = .white.withAlphaComponent(0.7)
        followerLabel.textAlignment = .left
        
        followButton.addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        followButton.addTarget(self, action: #selector(handleTouchUp), for: [.touchUpInside, .touchCancel, .touchDragExit])

        let textStack = UIStackView(arrangedSubviews: [usernameLabel, followerLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading

        let leftStack = UIStackView(arrangedSubviews: [avatarImageView, textStack])
        leftStack.axis = .horizontal
        leftStack.spacing = 10
        leftStack.alignment = .center

        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(leftStack)
        stackView.addArrangedSubview(followButton)

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }

    func configure(with post: Post.Model) {
        usernameLabel.text = post.author.username
        followerLabel.text = "\(post.author.followers.count) followers"

        if let avatarURL = post.author.avatarURL {
            avatarImageView.loadImage(from: avatarURL)
        } else {
            avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
            avatarImageView.tintColor = .white.withAlphaComponent(0.5)
        }
    }
    
    func updateFollowButton(title: String, isFollowing: Bool, animated: Bool = true) {
        let backgroundColor = isFollowing ? UIColor.darkGray : UIColor.systemPurple

        guard animated else {
            followButton.setTitle(title, for: .normal)
            followButton.configuration?.baseBackgroundColor = backgroundColor
            return
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.followButton.titleLabel?.alpha = 0
        })

        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.8,
            options: [.curveEaseInOut],
            animations: {
                self.followButton.setTitle(title, for: .normal)
                self.followButton.configuration?.baseBackgroundColor = backgroundColor
                self.followButton.titleLabel?.alpha = 1
                self.stackView.layoutIfNeeded()
            }
        )
    }
    
    @objc private func handleTouchDown() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut], animations: {
            self.followButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: nil)
    }

    @objc private func handleTouchUp() {
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.4,
                       options: [.curveEaseOut],
                       animations: {
            self.followButton.transform = .identity
        }, completion: nil)
    }
}
