//
//  OverlayMusicView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 12/05/2025.
//

import UIKit

final class OverlayMusicView: UIStackView {

    // MARK: - Subviews
    let musicLabel = UILabel()
    let artistLabel = UILabel()
    let musicCoverImageView = UIImageView()
    let addSongButton = UIButton(type: .system)

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
        spacing = 8
        alignment = .center
        setup()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setup() {
        // Music image
        musicCoverImageView.contentMode = .scaleAspectFill
        musicCoverImageView.clipsToBounds = true
        musicCoverImageView.layer.cornerRadius = 8
        musicCoverImageView.translatesAutoresizingMaskIntoConstraints = false
        musicCoverImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        musicCoverImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true

        // Music label
        musicLabel.font = .systemFont(ofSize: 12, weight: .medium)
        musicLabel.textColor = .white.withAlphaComponent(0.8)
        musicLabel.lineBreakMode = .byTruncatingTail
        musicLabel.numberOfLines = 1
        musicLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        musicLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Artist label
        artistLabel.font = .italicSystemFont(ofSize: 10)
        artistLabel.textColor = .white.withAlphaComponent(0.7)
        artistLabel.numberOfLines = 1

        // Add button
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 8, weight: .medium))
        config.imagePadding = 2
        config.imagePlacement = .leading
        config.attributedTitle = AttributedString("Add", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.7)
        ]))
        config.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4)
        config.background.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        config.background.cornerRadius = 4

        addSongButton.configuration = config
        addSongButton.tintColor = .white.withAlphaComponent(0.7)
        addSongButton.setContentHuggingPriority(.required, for: .horizontal)
        addSongButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        // Title row (musicLabel + add button)
        let titleRow = UIStackView(arrangedSubviews: [musicLabel, addSongButton])
        titleRow.axis = .horizontal
        titleRow.spacing = 8
        titleRow.alignment = .center
        titleRow.distribution = .fill

        // Text stack (title row + artist label)
        let textStack = UIStackView(arrangedSubviews: [titleRow, artistLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading
        textStack.distribution = .fill

        // Main horizontal layout
        addArrangedSubview(musicCoverImageView)
        addArrangedSubview(textStack)
    }
}
