//
//  OverlayView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 08/10/2025.
//

import UIKit

extension FeedFeature.UI.View {

    final class OverlayView: UIView {
        typealias Reaction = FeedFeature.UI.View.ReactionView.Reaction
        typealias ReactionView = FeedFeature.UI.View.ReactionView
        typealias UIConstants = FeedFeature.Support.Constants.UI
        
        private var reactions: [Reaction]?
        
        // MARK: - Subviews

        private let slider = CustomSlider()
        private let reactionView = ReactionView()
        private let capsuleList = HorizontalCapsuleListView()
        private let upperView = UIView()
        private let lowerView = UIView()
        private let backStack = UIStackView()
        
        let messageIcon = UIImageView()
        let badgeLabel = UILabel()
        let commentLabel = UILabel()
        let captionStack = UIStackView()

        // MARK: - Init

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configure(with reactions: [Reaction]) {
            self.reactions = reactions
            reactionView.configure(with: reactions)
        }

        // MARK: - Setup

        private func setupUI() {
            backgroundColor = .clear
            isUserInteractionEnabled = true

            setupSlider()
            setupLowerView()
            setupBackStack()
            setupReactionView()
        }

        private func setupBackStack() {
            backStack.axis = .vertical
            backStack.distribution = .fill
            backStack.alignment = .fill
            backStack.translatesAutoresizingMaskIntoConstraints = false

            addSubview(backStack)

            NSLayoutConstraint.activate([
                backStack.topAnchor.constraint(equalTo: topAnchor),
                backStack.leadingAnchor.constraint(equalTo: leadingAnchor),
                backStack.trailingAnchor.constraint(equalTo: trailingAnchor),
                backStack.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])

            backStack.addArrangedSubview(upperView)
            backStack.addArrangedSubview(lowerView)

            upperView.setContentHuggingPriority(.defaultLow, for: .vertical)
            upperView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            lowerView.setContentHuggingPriority(.required, for: .vertical)
            lowerView.setContentCompressionResistancePriority(.required, for: .vertical)
        }

        private func setupLowerView() {

            // MARK: Icon + Badge
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            messageIcon.image = UIImage(systemName: "message", withConfiguration: symbolConfig)
            messageIcon.tintColor = .white
            messageIcon.contentMode = .scaleAspectFit
            messageIcon.translatesAutoresizingMaskIntoConstraints = false

            badgeLabel.text = "12"
            badgeLabel.font = .systemFont(ofSize: 10, weight: .regular)
            badgeLabel.textColor = .white
            badgeLabel.backgroundColor = .systemRed.withAlphaComponent(0.8)
            badgeLabel.textAlignment = .center
            badgeLabel.layer.cornerRadius = 9
            badgeLabel.clipsToBounds = true
            badgeLabel.translatesAutoresizingMaskIntoConstraints = false

            let iconContainerView = UIView()
            iconContainerView.translatesAutoresizingMaskIntoConstraints = false
            iconContainerView.addSubview(messageIcon)
            iconContainerView.addSubview(badgeLabel)

            NSLayoutConstraint.activate([
                messageIcon.topAnchor.constraint(equalTo: iconContainerView.topAnchor),
                messageIcon.bottomAnchor.constraint(equalTo: iconContainerView.bottomAnchor),
                messageIcon.leadingAnchor.constraint(equalTo: iconContainerView.leadingAnchor),
                messageIcon.trailingAnchor.constraint(equalTo: iconContainerView.trailingAnchor),
                messageIcon.widthAnchor.constraint(equalToConstant: 28),
                messageIcon.heightAnchor.constraint(equalToConstant: 28),

                badgeLabel.topAnchor.constraint(equalTo: iconContainerView.topAnchor, constant: -4),
                badgeLabel.trailingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 4),
                badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 18),
                badgeLabel.heightAnchor.constraint(equalToConstant: 18)
            ])

            // MARK: Comment Preview
            commentLabel.text = "user42 : trop cool cette vidéo 🔥"
            commentLabel.font = .systemFont(ofSize: 13, weight: .regular)
            commentLabel.textColor = .white
            commentLabel.numberOfLines = 1
            commentLabel.lineBreakMode = .byTruncatingTail

            let commentStackView = UIStackView(arrangedSubviews: [iconContainerView, commentLabel])
            commentStackView.axis = .horizontal
            commentStackView.spacing = 8
            commentStackView.alignment = .center
            commentStackView.translatesAutoresizingMaskIntoConstraints = false
            commentStackView.isLayoutMarginsRelativeArrangement = true
            commentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16 + UIConstants.ReactionsView.width)

            // MARK: Caption
            let captionLabel = UILabel()
            captionLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. #hashtag"
            captionLabel.font = .systemFont(ofSize: 14, weight: .medium)
            captionLabel.textColor = .white
            captionLabel.numberOfLines = 2
            captionLabel.lineBreakMode = .byTruncatingTail

            let eyeIcon = UIImageView()
            let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
            eyeIcon.image = UIImage(systemName: "eye.fill", withConfiguration: config)
            eyeIcon.tintColor = .secondaryLabel
            eyeIcon.contentMode = .scaleAspectFit
            eyeIcon.translatesAutoresizingMaskIntoConstraints = false
            eyeIcon.setContentHuggingPriority(.required, for: .horizontal)

            let metadataLabel = UILabel()
            metadataLabel.text = "1.2k · Paris · 2h"
            metadataLabel.font = .systemFont(ofSize: 12, weight: .regular)
            metadataLabel.textColor = .secondaryLabel

            let metadataStack = UIStackView(arrangedSubviews: [eyeIcon, metadataLabel])
            metadataStack.axis = .horizontal
            metadataStack.spacing = 6
            metadataStack.alignment = .center
            metadataStack.translatesAutoresizingMaskIntoConstraints = false

            captionStack.addArrangedSubviews([captionLabel, metadataStack])
            captionStack.axis = .vertical
            captionStack.spacing = 2
            captionStack.translatesAutoresizingMaskIntoConstraints = false
            captionStack.isLayoutMarginsRelativeArrangement = true
            captionStack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16 + UIConstants.ReactionsView.width)

            // MARK: Capsule List

            capsuleList.translatesAutoresizingMaskIntoConstraints = false
            capsuleList.configure(with: ["#animeaux", "#voyages", "#cinéma", "#trend", "#sport", "#art", "#nature", "#music"])

            // MARK: Stack
            let stack = UIStackView(arrangedSubviews: [
                commentStackView,
                captionStack,
                capsuleList,
                slider
            ])
            stack.axis = .vertical
            stack.spacing = 8
            stack.setCustomSpacing(4, after: capsuleList)
            stack.translatesAutoresizingMaskIntoConstraints = false

            lowerView.addSubview(stack)
            lowerView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: lowerView.topAnchor),
                stack.bottomAnchor.constraint(equalTo: lowerView.bottomAnchor),
                stack.leadingAnchor.constraint(equalTo: lowerView.leadingAnchor),
                stack.trailingAnchor.constraint(equalTo: lowerView.trailingAnchor)
            ])
        }
        

        // MARK: - Setup
        
        private func setupReactionView() {
            reactionView.translatesAutoresizingMaskIntoConstraints = false
            reactionView.isUserInteractionEnabled = true
            addSubview(reactionView)

            NSLayoutConstraint.activate([
                reactionView.topAnchor.constraint(equalTo: topAnchor),
                reactionView.trailingAnchor.constraint(equalTo: trailingAnchor),
                reactionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16 - 24 - 4),
                reactionView.widthAnchor.constraint(equalToConstant: UIConstants.ReactionsView.width)
            ])
        }
        
        private func setupSlider() {
            slider.value = 0.4
            slider.minimumTrackTintColor = .accent.withAlphaComponent(0.6)
            slider.maximumTrackTintColor = .clear
            
            if #available(iOS 26.0, *) {
                slider.sliderStyle = .thumbless
            } else {
                // Fallback on earlier versions
            }
            slider.translatesAutoresizingMaskIntoConstraints = false
            // Ajouter les événements de touch
//            slider.addTarget(self, action: #selector(sliderDidBeginTouch), for: .touchDown)
//            slider.addTarget(self, action: #selector(sliderDidEndTouch), for: .touchUpInside)
//            slider.addTarget(self, action: #selector(sliderDidEndTouch), for: .touchUpOutside)
//            slider.addTarget(self, action: #selector(sliderDidEndTouch), for: .touchCancel)

            // Container (si nécessaire)
            addSubview(slider)
        }
        
        func setVisibility(_ visible: Bool) {
            guard
                messageIcon.alpha != (visible ? 1.0 : 0.0) ||
                badgeLabel.alpha != (visible ? 1.0 : 0.0) ||
                commentLabel.alpha != (visible ? 1.0 : 0.0) ||
                captionStack.alpha != (visible ? 1.0 : 0.0)
            else { return }

            // Icon
            animateVisibility(
                of: messageIcon,
                visible: visible,
                duration: 0.7,
                withTransform: true,
                easing: visible ? .curveEaseOut : .curveEaseIn
            )

            // Badge
            animateVisibility(
                of: badgeLabel,
                visible: visible,
                duration: 0.7,
                delay: 0.08,
                withTransform: true,
                easing: visible ? .curveEaseOut : .curveEaseIn
            )

            // Comment
            animateVisibility(
                of: commentLabel,
                visible: visible,
                duration: 0.35,
                withTransform: false,
                easing: visible ? .curveEaseOut : .curveEaseIn
            )

            // Caption
            animateVisibility(
                of: captionStack,
                visible: visible,
                duration: 0.35,
                withTransform: false,
                easing: visible ? .curveEaseOut : .curveEaseIn
            )
            
            capsuleList.animateAppearance(visible: visible)
            reactionView.animateAppearance(visible: visible)
        }
        
        private func animateVisibility(
            of view: UIView,
            visible: Bool,
            duration: TimeInterval = 0.4,
            delay: TimeInterval = 0.0,
            withTransform: Bool = false,
            scaleIn: CGFloat = 0.8,
            scaleOut: CGFloat = 0.85,
            spring: Bool = true,
            easing: UIView.AnimationOptions = .curveEaseOut
        ) {
            if visible {
                if withTransform {
                    view.transform = CGAffineTransform(scaleX: scaleIn, y: scaleIn)
                }
                view.alpha = 0
            }

            let animations = {
                view.alpha = visible ? 1.0 : 0.0
                if withTransform {
                    view.transform = visible ? .identity : CGAffineTransform(scaleX: scaleOut, y: scaleOut)
                }
            }

            if spring {
                UIView.animate(
                    withDuration: duration,
                    delay: delay,
                    usingSpringWithDamping: 0.6,
                    initialSpringVelocity: 0.8,
                    options: [.beginFromCurrentState, easing],
                    animations: animations
                )
            } else {
                UIView.animate(
                    withDuration: duration,
                    delay: delay,
                    options: [.beginFromCurrentState, easing],
                    animations: animations
                )
            }
        }
    }
}



final class CustomSlider: UISlider {
    /// Hauteur de la barre centrale (track)
    var trackHeight: CGFloat = 3.0

    /// Hauteur max souhaitée pour le slider (container)
    var maxTotalHeight: CGFloat = 12.0

    // Réduit la hauteur de la piste (track)
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let y = bounds.midY - trackHeight / 2
        return CGRect(x: bounds.minX, y: y, width: bounds.width, height: trackHeight)
    }

    // Gère la position verticale du thumb
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let defaultRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        let y = rect.midY - defaultRect.height / 2
        return CGRect(x: defaultRect.origin.x, y: y, width: defaultRect.width, height: defaultRect.height)
    }

    // Indique à Auto Layout qu’on ne veut pas plus que `maxTotalHeight`
    override var intrinsicContentSize: CGSize {
        let base = super.intrinsicContentSize
        return CGSize(width: base.width, height: maxTotalHeight)
    }
}
