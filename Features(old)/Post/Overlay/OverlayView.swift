//
//  OverlayView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 11/05/2025.
//

import UIKit

final class OverlayView: UIView, UIGestureRecognizerDelegate {
    
    // MARK: - Subviews
    
    private let mainStackView = UIStackView()
    private let headerView = OverlayHeaderView()
    
    private let horizontalStackView = UIStackView()
    private let bodyView = OverlayBodyView()
    private let reactionView = OverlayReactionsView()
    private let bottomSpacerView = UIView()
    private let _backDropView = CommentsView()
    private let backDropBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
    private var blurView: UIVisualEffectView?
    
    // MARK: - Layout
    private var pendingSafeAreaInsets: NSDirectionalEdgeInsets?
    private var bottomSpacerHeightConstraint: NSLayoutConstraint?
    
    // MARK: - State
    
    private var _scrollCoordinator: ScrollCoordinator?
    private var isBodyViewVisible = true
    
    private let reactions: [OverlayReactionsView.Reaction] = [
        .init(iconName: "heart.fill", count: "123K"),
        .init(iconName: "face.smiling.inverse", count: "12.3K"),
        .init(iconName: "hand.thumbsup.fill", count: "8.9K"),
        .init(iconName: "flame.fill", count: "6.4K"),
        .init(iconName: "star.fill", count: "63.7K"),
        .init(iconName: "moon.stars.fill", count: "4.5K"),
        .init(iconName: "paperplane.fill", count: "7.6K"),
        .init(iconName: "playstation.logo", count: "9.7K"),
        .init(iconName: "apple.image.playground", count: "67.1K"),
        .init(iconName: "apple.image.playground", count: "67.1K"),
        .init(iconName: "apple.image.playground", count: "67.1K"),
        .init(iconName: "apple.image.playground", count: "67.1K"),
        .init(iconName: "apple.image.playground", count: "67.1K"),
        .init(iconName: "apple.image.playground", count: "67.1K"),
        .init(iconName: "apple.image.playground", count: "67.1K")
    ]
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        
        bodyView.setContentVisible(true, animated: false)
        _backDropView.isHidden = true
        _backDropView.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private var lastHeaderHeight: CGFloat = 0

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let insets = pendingSafeAreaInsets else { return }
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let headerHeight = headerView.frame.height

        guard headerHeight > 0, headerHeight != lastHeaderHeight else { return }
        lastHeaderHeight = headerHeight
        
        let adjustedInsets = NSDirectionalEdgeInsets(
            top: headerHeight,
            leading: insets.leading,
            bottom: insets.bottom,
            trailing: insets.trailing
        )
        _backDropView.applySafeAreaInsets(adjustedInsets)
        
        
        bodyView.layoutIfNeeded()
        bodyView.descriptionStackView.layoutIfNeeded()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 1. Header
        let headerPoint = headerView.convert(point, from: self)
        if headerView.point(inside: headerPoint, with: event) {
            if let buttonView = headerView.hitTest(headerPoint, with: event), buttonView is UIControl {
                return buttonView
            }
            onRequestFeedScrollActivation?()
            return nil
        }
        
        let footerPoint = bottomSpacerView.convert(point, from: self)
        if bottomSpacerView.point(inside: footerPoint, with: event) {
            if let buttonView = bottomSpacerView.hitTest(footerPoint, with: event), buttonView is UIControl {
                return buttonView
            }
            onRequestFeedScrollActivation?()
            return nil
        }
        
        // 2. Réactions
        let collectionView = reactionView.collectionView
        let collectionPoint = collectionView.convert(point, from: self)
        if collectionView.point(inside: collectionPoint, with: event) {
            scrollCoordinator?.activate(collectionView)
            if let targetView = collectionView.hitTest(collectionPoint, with: event) {
                return targetView
            }
        }
//        else {
//            let reactionPoint = reactionView.convert(point, from: self)
//            if let targetView = reactionView.hitTest(reactionPoint, with: event) {
//                return targetView
//            }
//            onRequestFeedScrollActivation?()
//        }

        // 3. BodyView : laisser UIKit gérer normalement
        let bodyPoint = bodyView.convert(point, from: self)
        if bodyView.point(inside: bodyPoint, with: event), bodyView.isInteractable {
            onRequestFeedScrollActivation?()
            return bodyView.hitTest(bodyPoint, with: event)
        }

        // 4. Backdrop (ex: commentaires derrière)
        let backDropPoint = _backDropView.convert(point, from: self)
        if _backDropView.point(inside: backDropPoint, with: event) {
            // Active le scroll des commentaires
            _backDropView.activateScroll()
            // Ou si tu veux être plus générique : scrollCoordinator?.activate(_backDropView.collectionView)
            return _backDropView.hitTest(backDropPoint, with: event)
        }

        // 5. Autre
        return super.hitTest(point, with: event)
    }
    
    // MARK: - Setup Views & Layout
    
    private func setupViews() {
        backgroundColor = .clear
        
        
        // Backdrop (derrière tout)
        _backDropView.translatesAutoresizingMaskIntoConstraints = false
        backDropBlurView.translatesAutoresizingMaskIntoConstraints = false
        backDropBlurView.isHidden = true
        addSubview(backDropBlurView)
        addSubview(_backDropView)
        
        // StackView verticale
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill
        mainStackView.spacing = 0
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStackView)
        
        // HeaderView en haut de la stack
        headerView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.addArrangedSubview(headerView)
        
        // Container horizontal pour body + reactions
        mainStackView.addArrangedSubview(horizontalStackView)
        
        // Stack horizontale pour bodyView + reactionView
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .fill
        horizontalStackView.distribution = .fill
        reactionView.setContentHuggingPriority(.required, for: .horizontal)
        reactionView.setContentCompressionResistancePriority(.required, for: .horizontal)
        horizontalStackView.spacing = 0
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        reactionView.translatesAutoresizingMaskIntoConstraints = false
        
        horizontalStackView.addArrangedSubview(bodyView)
        horizontalStackView.addArrangedSubview(reactionView)
        
        // SpacerView pour safeArea bottom
        bottomSpacerView.translatesAutoresizingMaskIntoConstraints = false
        bottomSpacerView.backgroundColor = .clear
        mainStackView.addArrangedSubview(bottomSpacerView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backDropBlurView.topAnchor.constraint(equalTo: topAnchor),
            backDropBlurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backDropBlurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backDropBlurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            _backDropView.topAnchor.constraint(equalTo: topAnchor),
            _backDropView.leadingAnchor.constraint(equalTo: leadingAnchor),
            _backDropView.trailingAnchor.constraint(equalTo: reactionView.leadingAnchor),
            _backDropView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        // SpacerView (hauteur dynamique pour safeArea)
        bottomSpacerHeightConstraint = bottomSpacerView.heightAnchor.constraint(equalToConstant: 0)
        bottomSpacerHeightConstraint?.isActive = true
    }
    
    
    // MARK: - Public API
    
    var backDropView: CommentsView { _backDropView }
    
    var onRequestFeedScrollActivation: (() -> Void)?
    
    func configure(with post: Post.Model) {
        headerView.configure(with: post)
        bodyView.configure(with: post)
        reactionView.configure(with: reactions)
    }
    
    func applySafeAreaInsets(_ insets: NSDirectionalEdgeInsets) {
        headerView.applySafeAreaInsets(insets)
        bottomSpacerHeightConstraint?.constant = insets.bottom
        pendingSafeAreaInsets = insets
        setNeedsLayout()
    }
    
    func setBodyViewInteractionsEnabled(_ isEnabled: Bool) {
        mainStackView.isUserInteractionEnabled = isEnabled
        bodyView.isUserInteractionEnabled = isEnabled
    }
    
    var scrollCoordinator: ScrollCoordinator? {
        get { _scrollCoordinator }
        set {
            _scrollCoordinator = newValue
            _backDropView.scrollCoordinator = newValue
        }
    }
    
    /// Gestures
    var onTapInteractionLeft: (() -> Void)? {
        get { bodyView.onTapInteractionLeft }
        set { bodyView.onTapInteractionLeft = newValue }
    }
    
    var onTapInteractionRight: (() -> Void)? {
        get { bodyView.onTapInteractionRight }
        set { bodyView.onTapInteractionRight = newValue }
    }
    
    var onBackButtonTapped: (() -> Void)? {
        get { headerView.onBackButtonTapped }
        set { headerView.onBackButtonTapped = newValue }
    }
    
    var onFollowTapped: (() -> Void)? {
        get { headerView.onFollowTapped }
        set { headerView.onFollowTapped = newValue }
    }
    
    var onTickerTap: (() -> Void)? {
        get { bodyView.onTickerTap }
        set { bodyView.onTickerTap = newValue }
    }
    
    /// Blur Control
    func applyBackgroundBlur(style: UIBlurEffect.Style = .systemMaterialDark, duration: TimeInterval = 0.4) {
        guard blurView == nil else { return }
        
        let blur = UIVisualEffectView(effect: nil)
        blur.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(blur, at: 0)
        
        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: topAnchor),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor),
            blur.leadingAnchor.constraint(equalTo: leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
            blur.effect = UIBlurEffect(style: style)
        }
        animator.startAnimation()
        
        blurView = blur
    }
    
    func removeBackgroundBlur(duration: TimeInterval = 0.3) {
        guard let blurView = blurView else { return }
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
            blurView.effect = nil
        }
        
        animator.addCompletion { _ in
            blurView.removeFromSuperview()
            self.blurView = nil
        }
        
        animator.startAnimation()
    }
    
    func updateProgress(to index: Int) {
        guard index >= 0 else { return }
        bodyView.progressBarView.updateProgress(to: index)
    }
    
    func toggleBodyOrComments(animated: Bool = true) {
        isBodyViewVisible.toggle()
        
        // Affiche/Masque body
        bodyView.setContentVisible(isBodyViewVisible, animated: animated)
        
        // Affiche/Masque les commentaires
        backDropBlurView.isHidden = isBodyViewVisible
        _backDropView.isHidden = isBodyViewVisible
        _backDropView.isUserInteractionEnabled = !isBodyViewVisible
        _backDropView.activateScroll()
    }
    
    func configureProgressBar(count: Int, currentIndex: Int) {
        if count <= 1 {
            bodyView.updateProgressBarPresence(show: false)
        } else {
            bodyView.updateProgressBarPresence(show: true)
            bodyView.progressBarView.configureSegments(count: count, currentIndex: currentIndex)
        }
    }
}

extension NSDirectionalEdgeInsets {
    init(edgeInsets: UIEdgeInsets) {
        self.init(top: edgeInsets.top, leading: edgeInsets.left, bottom: edgeInsets.bottom, trailing: edgeInsets.right)
    }
}
