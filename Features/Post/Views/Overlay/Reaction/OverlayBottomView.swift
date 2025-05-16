//
//  OverlayBottomView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 30/04/2025.
//

import UIKit

final class OverlayBottomView: UIView {

    // MARK: - UI Elements

    private let descriptionLabel = UILabel()
    private let descriptionMetaStackView = UIStackView()
    private let metaLabel = UILabel()

    private let musicLabel = UILabel()
    private let addSongButton = UIButton(type: .system)
    private let artistLabel = UILabel()
    private let musicTextStackView = UIStackView()
    private let musicCoverImageView = UIImageView()
    private let musicContainer = UIStackView()
    private let textStackView = UIStackView()

    private let gradientView = UIView()
    private let backgroundGradient = CAGradientLayer()

    private let reactionsView = OverlayReactionsView()
    private let commentView = OverlayCommentView()

    private var containerBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Public API
    var reactionsScrollView: UIScrollView {
        return reactionsView.scrollView
    }

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
        setupGradientView()
        setupDescriptionMetaViews()
        setupMusicViews()
        setupTextStack()
        setupReactionsWrapper()
        setupMainContainer()
        setupConstraints()
        
        commentView.onTap = {
            print("comment view tapped")
        }
    }

    // MARK: - Setup Sections

    /// Sets up the background gradient layer.
    private func setupGradientView() {
        backgroundGradient.colors = [
            UIColor.black.withAlphaComponent(0.8).cgColor,
            UIColor.black.withAlphaComponent(0.4).cgColor,
            UIColor.clear.cgColor
        ]
        backgroundGradient.locations = [0.0, 0.8, 1.0]
        backgroundGradient.startPoint = CGPoint(x: 0, y: 1.0)
        backgroundGradient.endPoint = CGPoint(x: 0, y: 0.0)

        gradientView.layer.addSublayer(backgroundGradient)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gradientView)
    }

    /// Sets up the description and metadata labels and stack.
    private func setupDescriptionMetaViews() {
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 2
        descriptionLabel.lineBreakMode = .byTruncatingTail

        metaLabel.font = .systemFont(ofSize: 12)
        metaLabel.textColor = .white.withAlphaComponent(0.7)
        metaLabel.numberOfLines = 1
        metaLabel.lineBreakMode = .byTruncatingTail

        descriptionMetaStackView.axis = .vertical
        descriptionMetaStackView.spacing = 4
        descriptionMetaStackView.addArrangedSubview(descriptionLabel)
        descriptionMetaStackView.addArrangedSubview(metaLabel)
    }

    /// Sets up the music labels, image, and add button.
    private func setupMusicViews() {
        musicLabel.font = .systemFont(ofSize: 12, weight: .medium)
        musicLabel.textColor = .white.withAlphaComponent(0.8)
        musicLabel.numberOfLines = 1
        musicLabel.lineBreakMode = .byTruncatingTail
        musicLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        musicLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let font = UIFont.systemFont(ofSize: 12, weight: .medium)
        let color = UIColor.white.withAlphaComponent(0.7)

        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 8, weight: .medium))
        config.imagePadding = 2
        config.imagePlacement = .leading
        config.attributedTitle = AttributedString("Add", attributes: AttributeContainer([
            .font: font,
            .foregroundColor: color
        ]))
        config.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4)
        config.background.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        config.background.cornerRadius = 4

        addSongButton.configuration = config
        addSongButton.tintColor = color
        addSongButton.setContentHuggingPriority(.required, for: .horizontal)
        addSongButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        addSongButton.addTarget(self, action: #selector(addSongButtonTapped), for: .touchUpInside)

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let musicTitleRow = UIStackView(arrangedSubviews: [musicLabel, addSongButton, spacer])
        musicTitleRow.axis = .horizontal
        musicTitleRow.spacing = 8
        musicTitleRow.alignment = .center
        musicTitleRow.distribution = .fill

        artistLabel.font = .italicSystemFont(ofSize: 10)
        artistLabel.textColor = .white.withAlphaComponent(0.7)
        artistLabel.numberOfLines = 1
        artistLabel.lineBreakMode = .byTruncatingTail

        musicTextStackView.axis = .vertical
        musicTextStackView.spacing = 2
        musicTextStackView.addArrangedSubview(musicTitleRow)
        musicTextStackView.addArrangedSubview(artistLabel)

        musicCoverImageView.contentMode = .scaleAspectFill
        musicCoverImageView.clipsToBounds = true
        musicCoverImageView.layer.cornerRadius = 8
        musicCoverImageView.translatesAutoresizingMaskIntoConstraints = false
        musicCoverImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        musicCoverImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true

        musicContainer.axis = .horizontal
        musicContainer.spacing = 8
        musicContainer.alignment = .center
        musicContainer.addArrangedSubview(musicCoverImageView)
        musicContainer.addArrangedSubview(musicTextStackView)
    }

    /// Sets up the vertical stack that contains the description and music rows.
    private func setupTextStack() {
        commentView.isUserInteractionEnabled = true
        commentView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.axis = .vertical
        textStackView.spacing = 16
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.addArrangedSubview(descriptionMetaStackView)
        textStackView.addArrangedSubview(musicContainer)
    }

    /// Sets up a wrapper around the reactions view with padding.
    private func setupReactionsWrapper() {
        let reactionsWrapper = UIView()
        reactionsWrapper.translatesAutoresizingMaskIntoConstraints = false
        reactionsWrapper.addSubview(reactionsView)
        reactionsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            reactionsView.topAnchor.constraint(equalTo: reactionsWrapper.topAnchor),
            reactionsView.bottomAnchor.constraint(equalTo: reactionsWrapper.bottomAnchor),
            reactionsView.leadingAnchor.constraint(equalTo: reactionsWrapper.leadingAnchor),
            reactionsView.trailingAnchor.constraint(equalTo: reactionsWrapper.trailingAnchor, constant: -16)
        ])

        reactionsWrapper.tag = 999 // used later in setupMainContainer
        addSubview(reactionsWrapper)
    }

    /// Assembles the commentView, text, and reactions view into a horizontal container.
    private func setupMainContainer() {
        // Text container with padding
        let paddedTextStackContainer = UIView()
        paddedTextStackContainer.translatesAutoresizingMaskIntoConstraints = false
        paddedTextStackContainer.addSubview(textStackView)
        NSLayoutConstraint.activate([
            textStackView.topAnchor.constraint(equalTo: paddedTextStackContainer.topAnchor),
            textStackView.bottomAnchor.constraint(equalTo: paddedTextStackContainer.bottomAnchor),
            textStackView.leadingAnchor.constraint(equalTo: paddedTextStackContainer.leadingAnchor, constant: 16),
            textStackView.trailingAnchor.constraint(equalTo: paddedTextStackContainer.trailingAnchor)
        ])

        let verticalStack = UIStackView(arrangedSubviews: [commentView, paddedTextStackContainer])
        verticalStack.axis = .vertical
        verticalStack.spacing = 16

        // Retrieve previously added reactionsWrapper
        guard let reactionsWrapper = subviews.first(where: { $0.tag == 999 }) else { return }

        let containerStackView = UIStackView(arrangedSubviews: [verticalStack, reactionsWrapper])
        containerStackView.spacing = 8
        containerStackView.axis = .horizontal
        containerStackView.alignment = .bottom
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerStackView)

        containerBottomConstraint = containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        containerStackView.tag = 998 // to retrieve in setupConstraints
    }

    /// Adds all layout constraints to the view and its subviews.
    private func setupConstraints() {
        guard let containerStackView = subviews.first(where: { $0.tag == 998 }) else { return }

        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: commentView.bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor),

            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerBottomConstraint!
        ])

        sendSubviewToBack(gradientView)
    }
    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundGradient.frame = gradientView.bounds
    }

    // MARK: - Public Methods

    /// Configures all visual elements using post content
    func configure(with post: Post.Model) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.lineBreakMode = .byWordWrapping

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle
        ]

        descriptionLabel.attributedText = NSAttributedString(
            string: "Voici une super description de post avec lorem ipsum 1234 #hashtag",
            attributes: attributes
        )

        metaLabel.text = "2m ago ∙ Guangzhou, China"
        musicLabel.text = "♫ 侯波(江南版) 俊玄昌俊 & 侯波 - Single"
        artistLabel.text = "傲寒同学"

        if let avatarURL = post.author.avatarURL {
            musicCoverImageView.loadImage(from: avatarURL)
        } else {
            musicCoverImageView.image = UIImage(systemName: "music.quarternote.3")
            musicCoverImageView.tintColor = .white.withAlphaComponent(0.5)
        }

        commentView.configure(with: post)
    }

    /// Applies safe area insets (bottom spacing)
    func applySafeAreaInsets(_ insets: UIEdgeInsets) {
        containerBottomConstraint?.constant = -insets.bottom
    }
    
    @objc private func addSongButtonTapped() {
        print("button add song pressed")
    }
}
