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
    static let reuseIdentifier: String = "ProfileInfoViewCell"
}

final class ProfileInfoViewCell: UICollectionViewCell {
    private let avatar: UIImageView
    
    private let name: UILabel
    private let username: UILabel
    private let bio: UILabel
    
    private let followButton: CustomButton
    private let messageButton: CustomButton
    private let shareButton: CustomButton
    private let moreButton: CustomButton
    
    private let nameStack: UIStackView
    private let avatarNameStack: UIStackView
    private let countersStack: UIStackView
    private let buttonStack: UIStackView
    private let mainStack: UIStackView
    
    var topSpacing: CGFloat
    
    var bioFrameFrameInContentView: CGRect {
        return bio.frame
    }
    
    var nameFrameInContentView: CGRect {
        return name.frame
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        
        let targetSize = CGSize(width: layoutAttributes.size.width, height: UIView.layoutFittingCompressedSize.height)
        let size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        layoutAttributes.size.height = size.height
        return layoutAttributes
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        avatar = UIImageView()
        name = UILabel()
        username = UILabel()
        bio = UILabel()
        
        followButton = CustomButton()
        messageButton = Self.makeCustomButton(title: "Message", background: .systemGray5, textColor: .label)
        shareButton = Self.makeIconButton(systemName: "qrcode")
        moreButton = Self.makeIconButton(systemName: "ellipsis")
        
        nameStack = UIStackView()
        avatarNameStack = UIStackView()
        countersStack = UIStackView()
        buttonStack = UIStackView()
        mainStack = UIStackView()
        
        topSpacing = 128
        
        super.init(frame: frame)
        
        layer.masksToBounds = true
        
        setupAvatar()
        setupNameStack()
        setupAvatarNameStack()
        setupCounters()
        setupButtons()
        setupBio()
        setupMainStack()
        setupLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Setup
    
    private func setupAvatar() {
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular)
        avatar.image = UIImage(systemName: "person.crop.circle", withConfiguration: config)
        avatar.tintColor = .white
        avatar.contentMode = .scaleAspectFit
        avatar.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupNameStack() {
        name.font = .boldSystemFont(ofSize: 20)
        name.textColor = .white
        name.text = "Name"
        
        username.font = .preferredFont(forTextStyle: .footnote)
        username.textColor = .white
        username.text = "ID : id-1234"
        
        nameStack.axis = .vertical
        nameStack.spacing = 8
        nameStack.alignment = .leading
        nameStack.addArrangedSubview(name)
        nameStack.addArrangedSubview(username)
    }
    
    private func setupAvatarNameStack() {
        avatarNameStack.axis = .horizontal
        avatarNameStack.spacing = 12
        avatarNameStack.alignment = .center
        avatarNameStack.distribution = .fill
        avatarNameStack.addArrangedSubview(avatar)
        avatarNameStack.addArrangedSubview(nameStack)
    }
    
    private func setupCounters() {
        countersStack.axis = .horizontal
        countersStack.alignment = .fill
        countersStack.distribution = .fillEqually
        countersStack.spacing = 0
        
        Self.populateCountersStack(
            countersStack,
            values: [("0", "Following"), ("0", "Followers"), ("0", "Likes"), ("0", "Views")]
        )
    }
    
    private func setupButtons() {
        followButton.titleText = "Follow"
        followButton.invertTitleColors = true
        followButton.defaultBackgroundColor = .accent
        followButton.selectedBackgroundColor = .systemGray5
        followButton.directionalContentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        moreButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        shareButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fill
        buttonStack.alignment = .fill
        buttonStack.addArrangedSubviews([followButton, messageButton, shareButton, moreButton])
    }
    
    private func setupBio() {
        bio.font = .systemFont(ofSize: 14)
        bio.textColor = .white
        bio.numberOfLines = 0
        bio.textAlignment = .center
    }
    
    private func setupMainStack() {
        mainStack.axis = .vertical
        mainStack.spacing = 32
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        mainStack.addArrangedSubviews([
            avatarNameStack,
            countersStack,
            buttonStack,
            bio
        ])
    }
    
    private func setupLayout() {
        let gradientView = GradientView(colors: [.clear, .systemBackground.withAlphaComponent(0.75)])
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(gradientView)
        contentView.addSubview(mainStack)
        
        let bottomConstraint = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        bottomConstraint.priority = .defaultLow
        bottomConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            // Stack
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: topSpacing),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            // Avatar
            avatar.widthAnchor.constraint(equalToConstant: 80),
            avatar.heightAnchor.constraint(equalToConstant: 80),
            
            // Widths
            buttonStack.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
            countersStack.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
            
            // Gradient
            gradientView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
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
    
    private static func makeCustomButton(title: String, background: UIColor, textColor: UIColor) -> CustomButton {
        let button = CustomButton()
        button.titleText = title
        button.invertTitleColors = false
        button.directionalContentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        return button
    }
    
    private static func makeIconButton(systemName: String) -> CustomButton {
        let button = CustomButton()
        button.icon = UIImage(systemName: systemName)
        button.directionalContentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        return button
    }
    
    /// Remplit le stack des compteurs
    private static func populateCountersStack(_ stack: UIStackView, values: [(String, String)]) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
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
