//
//  OverlayBottomView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 30/04/2025.
//

import UIKit

final class OverlayBottomView: UIView {

    // MARK: - Subviews

    let descriptionView = OverlayDescriptionView()
    private let musicView = OverlayMusicView()
    let commentView = OverlayCommentView()

    let infoStackView = UIStackView()
    private let verticalStack = UIStackView()
    private var containerBottomConstraint: NSLayoutConstraint?
    let gradientAnchorView = UIView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Setup

    private func setup() {
        setupInfoStack()
        setupVerticalStack()
        setupGradientAnchor()
        setupConstraints()
    }

    private func setupInfoStack() {
        infoStackView.axis = .vertical
        infoStackView.spacing = 16
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.addArrangedSubview(descriptionView)
        infoStackView.addArrangedSubview(musicView)
    }

    private func setupVerticalStack() {
        verticalStack.axis = .vertical
        verticalStack.spacing = 12
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

        // Padded container uniquement pour infoStackView
        let paddedContainer = UIView()
        paddedContainer.translatesAutoresizingMaskIntoConstraints = false
        paddedContainer.addSubview(infoStackView)

        NSLayoutConstraint.activate([
            infoStackView.topAnchor.constraint(equalTo: paddedContainer.topAnchor),
            infoStackView.bottomAnchor.constraint(equalTo: paddedContainer.bottomAnchor),
            infoStackView.leadingAnchor.constraint(equalTo: paddedContainer.leadingAnchor, constant: 16),
            infoStackView.trailingAnchor.constraint(equalTo: paddedContainer.trailingAnchor)
        ])

        verticalStack.addArrangedSubview(commentView)
        verticalStack.addArrangedSubview(paddedContainer)
        addSubview(verticalStack)
    }

    private func setupConstraints() {
        containerBottomConstraint = verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor)

        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: topAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerBottomConstraint!
        ])
    }
    
    private func setupGradientAnchor() {
        gradientAnchorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gradientAnchorView)

        NSLayoutConstraint.activate([
            gradientAnchorView.topAnchor.constraint(equalTo: infoStackView.topAnchor),
            gradientAnchorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientAnchorView.widthAnchor.constraint(equalToConstant: 0),
            gradientAnchorView.heightAnchor.constraint(equalToConstant: 0)
        ])
    }

    // MARK: - Public API

    func configure(with post: Post.Model) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2

        descriptionView.descriptionLabel.attributedText = NSAttributedString(
            string: "Voici une super description de post avec lorem ipsum 1234 #hashtag",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
        )

        descriptionView.metaLabel.text = "2m ago ∙ Guangzhou, China"

        musicView.musicLabel.text = "♫ 侯波(江南版)"
        musicView.artistLabel.text = "傲寒同学"

        if let avatarURL = post.author.avatarURL {
            musicView.musicCoverImageView.loadImage(from: avatarURL)
        } else {
            musicView.musicCoverImageView.image = UIImage(systemName: "music.quarternote.3")
            musicView.musicCoverImageView.tintColor = .white.withAlphaComponent(0.5)
        }

        commentView.configure(with: post)
    }

    func applySafeAreaInsets(_ insets: UIEdgeInsets) {
        containerBottomConstraint?.constant = -insets.bottom
    }

    var addSongButton: UIButton {
        return musicView.addSongButton
    }

    var infoStackTopAnchor: NSLayoutYAxisAnchor {
        return infoStackView.topAnchor
    }
}
