//
//  GalleryHeaderView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/06/2025.
//

import UIKit

final class HeaderGalleryView: UIView {
    // MARK: - Subviews

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    private let headerContainerView = UIView()
        let backButton = UIButton(type: .system)
        let moreButton = UIButton(type: .system)
        private let bottomBorder = UIView()

        // Padding dynamique en haut (safeArea)
        var topPadding: CGFloat = 0 {
            didSet {
                buttonContainerTopConstraint?.constant = topPadding
            }
        }
        private var buttonContainerTopConstraint: NSLayoutConstraint?

        // Alpha blur animable
        var blurAlpha: CGFloat {
            get { blurView.alpha }
            set {
                blurView.alpha = newValue
                bottomBorder.alpha = newValue
            }
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            translatesAutoresizingMaskIntoConstraints = false
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.alpha = 0
            headerContainerView.translatesAutoresizingMaskIntoConstraints = false
            backButton.translatesAutoresizingMaskIntoConstraints = false
            moreButton.translatesAutoresizingMaskIntoConstraints = false
            bottomBorder.translatesAutoresizingMaskIntoConstraints = false

            bottomBorder.backgroundColor = .separator
            bottomBorder.alpha = 0

            addSubview(blurView)
            addSubview(headerContainerView)
            addSubview(bottomBorder)
            headerContainerView.addSubview(backButton)
            headerContainerView.addSubview(moreButton)

            // BlurView prend tout le header
            NSLayoutConstraint.activate([
                blurView.topAnchor.constraint(equalTo: topAnchor),
                blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
                blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
                blurView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])

            NSLayoutConstraint.activate([
                bottomBorder.heightAnchor.constraint(equalToConstant: 1),
                bottomBorder.leadingAnchor.constraint(equalTo: leadingAnchor),
                bottomBorder.trailingAnchor.constraint(equalTo: trailingAnchor),
                bottomBorder.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])

            // Container du bouton, padding dynamique en haut
            buttonContainerTopConstraint = headerContainerView.topAnchor.constraint(equalTo: topAnchor, constant: topPadding)
            NSLayoutConstraint.activate([
                buttonContainerTopConstraint!,
                headerContainerView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
                headerContainerView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
                headerContainerView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])

            // Config du bouton Back
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
            config.title = "Map"
            config.baseForegroundColor = .label
            config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 8)
            config.imagePadding = 4
            config.imagePlacement = .leading
            backButton.configuration = config

            // Config bouton "More" (3 dots)
            var moreConfig = UIButton.Configuration.plain()
            moreConfig.image = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
            moreConfig.baseForegroundColor = .label
            moreConfig.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 0)
            moreButton.configuration = moreConfig

            // Contraintes boutons (respecte tes paddings)
            NSLayoutConstraint.activate([
                backButton.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
                backButton.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
                backButton.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -8),

                moreButton.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
                moreButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
                moreButton.widthAnchor.constraint(equalToConstant: 32),
                moreButton.heightAnchor.constraint(equalToConstant: 32)
            ])
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
