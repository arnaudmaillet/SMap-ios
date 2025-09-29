//
//  ProfileInfoView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 28/07/2025.
//

import UIKit

final class GradientView: UIView {
    private let gradientLayer = CAGradientLayer()
    
    init(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)) {
        super.init(frame: .zero)
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        layer.addSublayer(gradientLayer)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

extension ProfileInfoViewCell {
    static let reuseIdentifier: String = "ProfileInfoView"
}

final class ProfileInfoViewCell: UICollectionViewCell {
    private let avatar = UIImageView()
    private let name = UILabel()
    private let countersStack = UIStackView()
    private let bio = UILabel()
    private let followButton: UIButton
    private let messageButton: UIButton
    private let shareButton: UIButton
    private let moreButton: UIButton
    private let buttonStack: UIStackView
    
    var bioFrameFrameInContentView: CGRect {
        return bio.frame
    }

    var nameFrameInContentView: CGRect {
        return name.frame
    }

    // MARK: - Init
    override init(frame: CGRect) {
        followButton = Self.makeButton(title: "Follow", background: .accent, textColor: .white)
        messageButton = Self.makeButton(title: "Message", background: .systemGray5, textColor: .label)
        shareButton = Self.makeIconButton(systemName: "qrcode")
        moreButton = Self.makeIconButton(systemName: "ellipsis")
        buttonStack = UIStackView(arrangedSubviews: [followButton, messageButton, shareButton, moreButton])
        super.init(frame: frame)
        
        contentView.backgroundColor = .clear
        contentView.layer.masksToBounds = true
        moreButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        // Avatar
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular)
        avatar.image = UIImage(systemName: "person.crop.circle", withConfiguration: config)
        avatar.tintColor = .white
        avatar.contentMode = .scaleAspectFit
        
        // Username
        name.font = .boldSystemFont(ofSize: 20)
        name.textColor = .white
        name.text = "Name"
        
        // Bio
        bio.font = .systemFont(ofSize: 14)
        bio.textColor = .white
        bio.numberOfLines = 0
        bio.textAlignment = .natural
        
        let gradientView = GradientView(colors: [.clear, .systemBackground.withAlphaComponent(0.75)])
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        // --- Compteurs équilibrés ---
        countersStack.axis = .horizontal
        countersStack.alignment = .fill
        countersStack.distribution = .fillEqually
        countersStack.spacing = 0
        Self.populateCountersStack(countersStack, values: [("0", "Following"), ("0", "Followers"), ("0", "Likes"), ("0", "Views")])
        
        // Boutons
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fill
        buttonStack.alignment = .fill
        
        // Stack principal
        let stack = UIStackView(arrangedSubviews: [avatar, name, countersStack, buttonStack, bio])
        stack.axis = .vertical
        stack.spacing = 32
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(gradientView)
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            // Stack
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 128),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -32),
            
            // Avatar + boutons
            avatar.widthAnchor.constraint(equalToConstant: 80),
            avatar.heightAnchor.constraint(equalToConstant: 80),
            buttonStack.widthAnchor.constraint(equalTo: stack.widthAnchor),
            countersStack.widthAnchor.constraint(equalTo: stack.widthAnchor),
            
            // Gradient
            gradientView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configure
    func configure(with user: User) {
        // Avatar
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular)
        avatar.image = UIImage(systemName: "person.crop.circle", withConfiguration: config)
        avatar.tintColor = .white.withAlphaComponent(0.5)
        
        // Name & bio
        name.text = user.username
        bio.text = user.bio ?? "Aucune bio"
        
        // Update counters
        let counters = [
            FormatterUtils.format(user.following.count),
            FormatterUtils.format(user.followers.count),
            FormatterUtils.format(Int.random(in: 0...5000)),
            FormatterUtils.format(Int.random(in: 0...50_000))
        ]
        
        for (index, view) in countersStack.arrangedSubviews.enumerated() {
            if let counterStack = view as? UIStackView,
               let valueLabel = counterStack.arrangedSubviews.first as? UILabel {
                valueLabel.text = counters[index]
            }
        }
    }
    
    // MARK: - Helpers
    
    private static func makeButton(title: String, background: UIColor, textColor: UIColor) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = background
        config.baseForegroundColor = textColor
        config.cornerStyle = .large
        config.titleLineBreakMode = .byTruncatingTail
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        return UIButton(configuration: config)
    }
    
    private static func makeIconButton(systemName: String) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: systemName)
        config.baseBackgroundColor = .systemGray5
        config.baseForegroundColor = .label
        config.cornerStyle = .large
        config.titleLineBreakMode = .byClipping
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        return UIButton(configuration: config)
    }
    
    /// Remplit le stack des compteurs
    private static func populateCountersStack(_ stack: UIStackView, values: [(String, String)]) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() } // reset
        
        for (index, item) in values.enumerated() {
            let counterView = makeCounterView(value: item.0, label: item.1)
            stack.addArrangedSubview(counterView)
            
            // Séparateur
            if index < values.count - 1 {
                let separator = UIView()
                separator.backgroundColor = .white
                separator.translatesAutoresizingMaskIntoConstraints = false
                counterView.addSubview(separator)
                NSLayoutConstraint.activate([
                    separator.widthAnchor.constraint(equalToConstant: 1),
                    separator.topAnchor.constraint(equalTo: counterView.topAnchor, constant: 8),
                    separator.bottomAnchor.constraint(equalTo: counterView.bottomAnchor, constant: -8),
                    separator.trailingAnchor.constraint(equalTo: counterView.trailingAnchor)
                ])
            }
        }
    }
    
    /// Crée un compteur (valeur + label)
    private static func makeCounterView(value: String, label: String) -> UIStackView {
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .boldSystemFont(ofSize: 16)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .center
        
        let labelLabel = UILabel()
        labelLabel.text = label
        labelLabel.font = .systemFont(ofSize: 12)
        labelLabel.textColor = .white
        labelLabel.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [valueLabel, labelLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 2
        return stack
    }
}
