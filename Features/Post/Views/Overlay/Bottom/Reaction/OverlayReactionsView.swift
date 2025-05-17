//
//  OverlayReactionsView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 30/04/2025.
//

import UIKit

// MARK: - ScrollTrapView

/// A UIScrollView subclass that disables user scrolling and intercepts gesture recognizers.
final class ScrollTrapView: UIScrollView, UIGestureRecognizerDelegate {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        isScrollEnabled = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        alwaysBounceHorizontal = false
        alwaysBounceVertical = false
        bounces = false
        isPagingEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        contentInsetAdjustmentBehavior = .never

        panGestureRecognizer.delegate = self
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

// MARK: - OverlayReactionsView

/// A view displaying interactive reaction buttons inside a scrollable list.
final class OverlayReactionsView: UIView, UIScrollViewDelegate {

    // MARK: - Constants

    private static let itemSpacing: CGFloat = 8.0
    private static let itemHeight: CGFloat = 56.0
    private let fadeDistance: CGFloat = 32
    private let visibleItemCount: Int = 4 // Nombre d’éléments visibles pour un scrollView aligné

    // MARK: - UI Components

    private let starButton = makeStaticButton(iconName: "star.fill", count: "2.3k")
    private let shareButton = makeStaticButton(iconName: "arrowshape.turn.up.forward.fill")
    private let fixedActionView = makeReactionStyledButton(iconName: "plus")
    private let mainStackView = UIStackView()
    private let reactionsContainer = UIView()
    private let scrollTrapView = ScrollTrapView()
    private let reactionsScrollView = UIScrollView()
    private let reactionsStackView = UIStackView()

    // MARK: - Constraints

    private var bottomConstraint: NSLayoutConstraint?

    // MARK: - Public API

    var scrollView: UIScrollView {
        return reactionsScrollView
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Setup UI

    private func setup() {
        setupHierarchy()
        setupConstraints()
    }

    private func setupHierarchy() {
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        reactionsContainer.translatesAutoresizingMaskIntoConstraints = false
        reactionsContainer.clipsToBounds = true

        reactionsScrollView.translatesAutoresizingMaskIntoConstraints = false
        reactionsScrollView.showsVerticalScrollIndicator = false
        reactionsScrollView.isScrollEnabled = true
        reactionsScrollView.delegate = self

        reactionsStackView.axis = .vertical
        reactionsStackView.alignment = .fill
        reactionsStackView.spacing = Self.itemSpacing
        reactionsStackView.translatesAutoresizingMaskIntoConstraints = false

        reactionsScrollView.addSubview(reactionsStackView)
        scrollTrapView.addSubview(reactionsScrollView)
        reactionsContainer.addSubview(scrollTrapView)

        mainStackView.addArrangedSubview(reactionsContainer)
        mainStackView.addArrangedSubview(starButton)
        mainStackView.addArrangedSubview(shareButton)
        addSubview(mainStackView)
        addSubview(fixedActionView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // stack inside scrollView
            reactionsStackView.topAnchor.constraint(equalTo: reactionsScrollView.topAnchor),
            reactionsStackView.leadingAnchor.constraint(equalTo: reactionsScrollView.leadingAnchor),
            reactionsStackView.trailingAnchor.constraint(equalTo: reactionsScrollView.trailingAnchor),
            reactionsStackView.bottomAnchor.constraint(equalTo: reactionsScrollView.bottomAnchor),
            reactionsStackView.widthAnchor.constraint(equalTo: reactionsScrollView.widthAnchor),

            // scrollView inside trap
            reactionsScrollView.topAnchor.constraint(equalTo: scrollTrapView.topAnchor),
            reactionsScrollView.leadingAnchor.constraint(equalTo: scrollTrapView.leadingAnchor),
            reactionsScrollView.trailingAnchor.constraint(equalTo: scrollTrapView.trailingAnchor),
            reactionsScrollView.bottomAnchor.constraint(equalTo: scrollTrapView.bottomAnchor),
            reactionsScrollView.heightAnchor.constraint(equalTo: scrollTrapView.heightAnchor),
            reactionsScrollView.widthAnchor.constraint(equalTo: scrollTrapView.widthAnchor),

            // trap in container
            scrollTrapView.topAnchor.constraint(equalTo: reactionsContainer.topAnchor, constant: 16),
            scrollTrapView.leadingAnchor.constraint(equalTo: reactionsContainer.leadingAnchor),
            scrollTrapView.trailingAnchor.constraint(equalTo: reactionsContainer.trailingAnchor),
            scrollTrapView.bottomAnchor.constraint(equalTo: reactionsContainer.bottomAnchor, constant: -16),

            // main stack
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        bottomConstraint = mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottomConstraint?.isActive = true

        let heightConstraint = reactionsContainer.heightAnchor.constraint(lessThanOrEqualTo: mainStackView.heightAnchor)
        heightConstraint.priority = .required
        heightConstraint.isActive = true

        let intrinsicHeightConstraint = reactionsContainer.heightAnchor.constraint(equalTo: reactionsStackView.heightAnchor)
        intrinsicHeightConstraint.priority = .defaultLow
        intrinsicHeightConstraint.isActive = true

        // 🔢 Forcer la hauteur du scrollTrapView à un multiple exact des items visibles
        let contentHeight = CGFloat(visibleItemCount) * (Self.itemHeight + Self.itemSpacing)
        scrollTrapView.heightAnchor.constraint(equalToConstant: contentHeight + 40).isActive = true

        NSLayoutConstraint.activate([
            fixedActionView.bottomAnchor.constraint(equalTo: reactionsScrollView.bottomAnchor, constant: 16),
            fixedActionView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    // MARK: - Configuration

    func configure(with reactions: [(String, String)]) {
        let topSpacer = UIView()
        topSpacer.translatesAutoresizingMaskIntoConstraints = false
        topSpacer.heightAnchor.constraint(equalToConstant: 16).isActive = true
        reactionsStackView.addArrangedSubview(topSpacer)

        for reaction in reactions {
            reactionsStackView.addArrangedSubview(Self.makeButton(iconName: reaction.0, count: reaction.1))
        }

        let bottomSpacer = UIView()
        bottomSpacer.translatesAutoresizingMaskIntoConstraints = false
        bottomSpacer.heightAnchor.constraint(equalToConstant: 16).isActive = true
        reactionsStackView.addArrangedSubview(bottomSpacer)
    }

    func applySafeAreaInsets(_ insets: UIEdgeInsets) {
        bottomConstraint?.constant = -insets.bottom
    }

    // MARK: - ScrollView Delegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        applyScaleEffect()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                    withVelocity velocity: CGPoint,
                                    targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetY = targetContentOffset.pointee.y
        let itemIndex = round(targetY / (Self.itemHeight + Self.itemSpacing))
        let snapOffset = itemIndex * (Self.itemHeight + Self.itemSpacing)
        targetContentOffset.pointee.y = max(0, snapOffset)
    }

    // MARK: - Effects

    private func applyScaleEffect() {
        guard let window = window else { return }
        let visibleRect = scrollView.convert(scrollView.bounds, to: window)
        let topThreshold = visibleRect.minY + fadeDistance + 16
        let bottomThreshold = visibleRect.maxY - fadeDistance

        for reactionView in reactionsStackView.arrangedSubviews {
            let frameInWindow = reactionView.convert(reactionView.bounds, to: window)
            let centerY = frameInWindow.midY

            var scale: CGFloat = 1.0
            var alpha: CGFloat = 1.0

            if centerY < topThreshold {
                let distance = topThreshold - centerY
                let ratio = min(1, distance / fadeDistance)
                alpha = 1 - ratio
            } else if centerY > bottomThreshold {
                let distance = centerY - bottomThreshold
                let ratio = min(1, distance / fadeDistance)
                alpha = 1 - ratio
                scale = 1 - ratio
            }

            reactionView.alpha = alpha
            reactionView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }

    // MARK: - Factory Methods

    private static func makeButton(iconName: String, count: String) -> UIView {
        guard let image = UIImage(systemName: iconName) else {
            print("⚠️ SF Symbol non trouvé: \(iconName)")
            return UIView()
        }

        // Icône
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true

        // Capsule noire semi-transparente
        let iconBackground = UIView()
        iconBackground.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        iconBackground.layer.cornerRadius = 16
        iconBackground.clipsToBounds = false
        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        iconBackground.layer.borderWidth = 1
        iconBackground.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        iconBackground.layer.shadowColor = UIColor.black.cgColor
        iconBackground.layer.shadowOpacity = 0.3
        iconBackground.layer.shadowRadius = 4
        iconBackground.layer.shadowOffset = CGSize(width: 0, height: 2)

        iconBackground.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: iconBackground.topAnchor, constant: 4),
            imageView.bottomAnchor.constraint(equalTo: iconBackground.bottomAnchor, constant: -4),
            imageView.leadingAnchor.constraint(equalTo: iconBackground.leadingAnchor, constant: 4),
            imageView.trailingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: -4)
        ])

        // Label
        let label = UILabel()
        label.text = count
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center

        // Stack vertical (image + label)
        let contentStack = UIStackView(arrangedSubviews: [iconBackground, label])
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 4
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        // Conteneur pour forcer la hauteur
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: itemHeight).isActive = true

        container.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        container.accessibilityIdentifier = "\(iconName)-\(count)"
        return container
    }
    
    private static func makeReactionStyledButton(iconName: String) -> UIView {
        guard let image = UIImage(systemName: iconName) else {
            print("⚠️ SF Symbol non trouvé: \(iconName)")
            return UIView()
        }

        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true

        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.accent
        backgroundView.layer.cornerRadius = 16
        backgroundView.layer.borderWidth = 1
        backgroundView.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOpacity = 0.3
        backgroundView.layer.shadowRadius = 4
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.clipsToBounds = false

        backgroundView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 4),
            imageView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -4),
            imageView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 4),
            imageView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -4)
        ])

        return backgroundView
    }
    
    
    private static func makeStaticButton(iconName: String, count: String? = nil) -> UIView {
        guard let image = UIImage(systemName: iconName) else { return UIView() }

        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 32).isActive = true

        // Stack toujours présent pour alignement cohérent
        let stack: UIStackView

        if let count = count {
            let label = UILabel()
            label.text = count
            label.font = .systemFont(ofSize: 12)
            label.textColor = .white
            label.textAlignment = .center

            stack = UIStackView(arrangedSubviews: [imageView, label])
        } else {
            stack = UIStackView(arrangedSubviews: [imageView])
        }

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }
}


