//
//  OverlayMusicView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 12/05/2025.
//

import UIKit

final class OverlayMusicView: UIStackView {

    // MARK: - Subviews
    private let _musicLabel = UILabel()
    private let _artistLabel = UILabel()
    private let _musicCoverImageView = UIImageView()
    private let _addSongButton = UIButton(type: .system)

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
        _musicCoverImageView.contentMode = .scaleAspectFill
        _musicCoverImageView.clipsToBounds = true
        _musicCoverImageView.layer.cornerRadius = 8
        _musicCoverImageView.translatesAutoresizingMaskIntoConstraints = false
        
        defaultWidthConstraint = _musicCoverImageView.widthAnchor.constraint(equalToConstant: 32)
        defaultHeightConstraint = _musicCoverImageView.heightAnchor.constraint(equalToConstant: 32)
        defaultWidthConstraint.isActive = true
        defaultHeightConstraint.isActive = true

        // Music label
        _musicLabel.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .medium)
        _musicLabel.textColor = .white.withAlphaComponent(0.8)
        _musicLabel.lineBreakMode = .byTruncatingTail
        _musicLabel.numberOfLines = 1
        _musicLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        _musicLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Artist label
        _artistLabel.font = .italicSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption2).pointSize)
        _artistLabel.textColor = .white.withAlphaComponent(0.7)
        _artistLabel.numberOfLines = 1
        
        artistLabelHeightConstraint = _artistLabel.heightAnchor.constraint(equalToConstant: _artistLabel.font.lineHeight)
        artistLabelHeightConstraint.isActive = true

        // Add button
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .medium))
        config.imagePadding = 2
        config.imagePlacement = .leading
        config.attributedTitle = AttributedString("Add", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.7)
        ]))
        config.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4)
        config.background.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        config.background.cornerRadius = 4

        _addSongButton.configuration = config
        _addSongButton.tintColor = .white.withAlphaComponent(0.7)
        _addSongButton.setContentHuggingPriority(.required, for: .horizontal)
        _addSongButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        // Title row (_musicLabel + add button)
        let titleRow = UIStackView(arrangedSubviews: [_musicLabel, _addSongButton])
        titleRow.axis = .horizontal
        titleRow.spacing = 8
        titleRow.alignment = .center
        titleRow.distribution = .fill

        // Text stack (title row + artist label)
        let textStack = UIStackView(arrangedSubviews: [titleRow, _artistLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading
        textStack.distribution = .fill
        

        // Main horizontal layout
        addArrangedSubviews([_musicCoverImageView, textStack])
    }
    
    // MARK: - Public API
    
    var musicLabel: UILabel { _musicLabel }
    var artistLabel: UILabel { _artistLabel }
    var musicCoverImageView: UIImageView { _musicCoverImageView }
    var addSongButton: UIButton { _addSongButton }
    
    var defaultWidthConstraint: NSLayoutConstraint!
    var defaultHeightConstraint: NSLayoutConstraint!
    var artistLabelHeightConstraint: NSLayoutConstraint!
}
