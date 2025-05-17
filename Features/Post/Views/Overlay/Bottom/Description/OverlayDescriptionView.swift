//
//  OverlayDescriptionView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 12/05/2025.
//

import UIKit

final class OverlayDescriptionView: UIStackView {

    // MARK: - Subviews
    let descriptionLabel = UILabel()
    let metaLabel = UILabel()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .vertical
        spacing = 4
        setup()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setup() {
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 2
        descriptionLabel.lineBreakMode = .byTruncatingTail

        metaLabel.font = .systemFont(ofSize: 12)
        metaLabel.textColor = .white.withAlphaComponent(0.7)

        addArrangedSubview(descriptionLabel)
        addArrangedSubview(metaLabel)
    }
}
