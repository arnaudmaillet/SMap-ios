//
//  OverlayDescriptionView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 12/05/2025.
//

import UIKit

final class OverlayDescriptionView: UIStackView {

    // MARK: - Subviews
    private var _descriptionLabel = UILabel()
    private var _metaLabel = UILabel()

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
        _descriptionLabel.font = .preferredFont(forTextStyle: .callout)
        _descriptionLabel.textColor = .white
        _descriptionLabel.numberOfLines = 2
        _descriptionLabel.lineBreakMode = .byTruncatingTail

        _metaLabel.font = .preferredFont(forTextStyle: .caption1)
        _metaLabel.textColor = .white.withAlphaComponent(0.7)
        
        addArrangedSubviews([_descriptionLabel, _metaLabel])
    }
    
    // MARK: - Public API
    
    var descriptionLabel: UILabel { _descriptionLabel }
    var metaLabel: UILabel { _metaLabel }
}
