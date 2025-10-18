//
//  ProfileHeaderView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 25/07/2025.
//

import UIKit

final class ProfileHeaderView: UIView {
    // MARK: - Subviews
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    private let gradientMask = CAGradientLayer()

    private let followButton = CustomButton()
    private let backButton = UIButton(type: .system)
    private var isInfoVisible = false

    private let headerStackView = UIStackView()
    private let infoStackView = UIStackView()
    private let nameStackView = UIStackView()

    private let usernameLabel = UILabel()
    private let followerLabel = UILabel()
    private let avatarImageView = UIImageView()
    
    var onBackTapped: (() -> Void)?

    // MARK: - Layout state
    var topPadding: CGFloat = 0 {
        didSet {
            buttonContainerTopConstraint?.constant = topPadding
            invalidateIntrinsicContentSize()
        }
    }
    private var buttonContainerTopConstraint: NSLayoutConstraint?

    // MARK: - Public animatable props
    var blurAlpha: CGFloat {
        get { blurView.alpha }
        set { blurView.alpha = newValue }
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBase()
        setupBlur()
        setupStacks()
        setupButtons()
        setupInfoViews()
        setupHierarchy()
        setupConstraints()
//        setupGradientMask()
        applyInitialVisibility()
        wireActions()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup (decomposed)
    private func setupBase() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
    }

    private func setupBlur() {
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.alpha = 0
    }

    private func setupStacks() {
        headerStackView.axis = .horizontal
        headerStackView.alignment = .center
        headerStackView.distribution = .equalSpacing
        headerStackView.spacing = 8
        headerStackView.translatesAutoresizingMaskIntoConstraints = false

        infoStackView.axis = .horizontal
        infoStackView.spacing = 8
        infoStackView.alignment = .center

        nameStackView.axis = .vertical
        nameStackView.spacing = 2
        nameStackView.alpha = 0
    }

    private func setupButtons() {
        var backConfig = UIButton.Configuration.plain()
        backConfig.image = UIImage(
            systemName: "chevron.left",
            withConfiguration: UIImage.SymbolConfiguration(weight: .bold)
        )
        backConfig.title = "Back"
        backConfig.baseForegroundColor = .white
        backConfig.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 8)
        backConfig.imagePadding = 4
        backConfig.imagePlacement = .leading
        backButton.configuration = backConfig

        followButton.directionalContentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        followButton.selectedBackgroundColor = .systemGray5
        followButton.defaultBackgroundColor = .accent
        followButton.invertTitleColors = true
        followButton.setTitle("Follow", for: .normal)
        followButton.alpha = 0

        backButton.translatesAutoresizingMaskIntoConstraints = false
        followButton.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupInfoViews() {
        // Avatar
        avatarImageView.layer.cornerRadius = 16
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.backgroundColor = .lightGray
        avatarImageView.alpha = 0

        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 32),
            avatarImageView.heightAnchor.constraint(equalToConstant: 32)
        ])

        // Labels
        usernameLabel.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .medium)
        usernameLabel.textColor = .black
        usernameLabel.numberOfLines = 1

        followerLabel.font = .preferredFont(forTextStyle: .caption1)
        followerLabel.textColor = .black.withAlphaComponent(0.7)
        followerLabel.numberOfLines = 1

        nameStackView.addArrangedSubview(usernameLabel)
        nameStackView.addArrangedSubview(followerLabel)
    }

    private func setupHierarchy() {
        addSubview(blurView)
        addSubview(headerStackView)

        infoStackView.addArrangedSubview(avatarImageView)
        infoStackView.addArrangedSubview(nameStackView)
        infoStackView.addArrangedSubview(followButton)

        headerStackView.addArrangedSubview(backButton)
        headerStackView.addArrangedSubview(infoStackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        buttonContainerTopConstraint = headerStackView
            .topAnchor
            .constraint(equalTo: topAnchor, constant: topPadding)

        NSLayoutConstraint.activate([
            buttonContainerTopConstraint!,
            headerStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            headerStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            headerStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupGradientMask() {
        gradientMask.colors = [
            UIColor.black.cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor
        ]
        gradientMask.locations = [0, 0.5, 1]
        gradientMask.startPoint = CGPoint(x: 0.5, y: 0)
        gradientMask.endPoint = CGPoint(x: 0.5, y: 1)
        blurView.layer.mask = gradientMask
    }

    private func applyInitialVisibility() {
        // ensure initial state matches isInfoVisible = false
        avatarImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        nameStackView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        followButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientMask.frame = bounds
    }

    override var intrinsicContentSize: CGSize {
        let buttonHeight: CGFloat = 44
        return CGSize(width: UIView.noIntrinsicMetric, height: topPadding + buttonHeight + 8 + 1)
    }

    // MARK: - Public API
    func configure(with user: User) {
        usernameLabel.text = user.username
        followerLabel.text = "12k followers"

        avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
        avatarImageView.tintColor = .white.withAlphaComponent(0.5)
        followButton.setTitle("Follow", for: .normal)
    }

    func setInfoVisible(_ visible: Bool, animated: Bool = true) {
        guard visible != isInfoVisible else { return }
        isInfoVisible = visible

        let initialScale: CGFloat = visible ? 1.2 : 1.0
        let targetScale: CGFloat = visible ? 1.0 : 0.8
        let targetAlpha: CGFloat = visible ? 1 : 0

        if animated {
            if visible {
                [avatarImageView, nameStackView, followButton].forEach {
                    $0.alpha = 0
                    $0.transform = CGAffineTransform(scaleX: initialScale, y: initialScale)
                }
            }

            UIView.animate(
                withDuration: 0.6,
                delay: visible ? 0 : 0.1,
                usingSpringWithDamping: 0.65,
                initialSpringVelocity: 1.85,
                options: [.curveEaseInOut]
            ) {
                self.followButton.alpha = targetAlpha
                self.followButton.transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
            }

            UIView.animate(
                withDuration: 0.6,
                delay: visible ? 0.1 : 0,
                usingSpringWithDamping: 0.65,
                initialSpringVelocity: 1.85,
                options: [.curveEaseInOut]
            ) {
                self.avatarImageView.alpha = targetAlpha
                self.avatarImageView.transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
                self.nameStackView.alpha = targetAlpha
                self.nameStackView.transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
            }
        } else {
            [avatarImageView, nameStackView, followButton].forEach {
                $0.alpha = targetAlpha
                $0.transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
            }
        }
    }

    func setBackButtonColor(_ color: UIColor, animated: Bool = true) {
        guard backButton.configuration?.baseForegroundColor != color else { return }
        if animated {
            UIView.transition(with: backButton, duration: 0.25, options: .transitionCrossDissolve) {
                self.backButton.configuration?.baseForegroundColor = color
            }
        } else {
            backButton.configuration?.baseForegroundColor = color
        }
    }

    func updateBlurProgress(_ progress: CGFloat) {
        let clamped = max(0, min(1, progress))
        let topAlpha: CGFloat = 1.0
        let midAlpha: CGFloat = 0.8 + 0.2 * clamped
        let bottomAlpha: CGFloat = 0.0 + 1.0 * clamped

        gradientMask.colors = [
            UIColor.black.withAlphaComponent(topAlpha).cgColor,
            UIColor.black.withAlphaComponent(midAlpha).cgColor,
            UIColor.black.withAlphaComponent(bottomAlpha).cgColor
        ]
    }
    
    private func wireActions() {
        backButton.addAction(UIAction { [weak self] _ in
            self?.onBackTapped?()
        }, for: .touchUpInside)
    }
}
