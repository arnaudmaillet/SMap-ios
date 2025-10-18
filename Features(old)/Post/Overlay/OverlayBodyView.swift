//
//  OverlayBodyInfoView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 30/04/2025.
//

import UIKit

final class OverlayBodyView: UIView {
    
    // MARK: - Subviews
    
    private let stackView = UIStackView()
    private let _interactionStackView = UIStackView()
    
    private let _tickerView = OverlayTickerView()
    private let _progressBarView = OverlayProgressBarView()
    
    private let infoContainerView = UIView()
    private let infoStack = UIStackView()
    
    private let _descriptionView = OverlayDescriptionView()
    private let _musicView = OverlayMusicView()
    
    private let _gradientAnchorGuide = UILayoutGuide()
    
    private var isContentVisible = true
    var descriptionContainerView: UIView { infoContainerView }
    var descriptionView: UIView { _descriptionView }
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupInteraction()
        setupProgressBar()
        setupInfoStackView()
        setupLayout()
        setContentVisible(true, animated: false)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    // MARK: - Setup
    
    private func setupView() {
        // verticalStackView stack setup
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Ajouter tes éléments à la stack
        stackView.addArrangedSubviews([
            _interactionStackView,
            _tickerView,
            _progressBarView,
            wrapWithPadding(infoContainerView, left: 8, right: 8)
        ])

        addSubview(stackView)
        // Gradient anchor ou autres extras
        addLayoutGuide(gradientAnchorGuide)
        
        _interactionStackView.setContentHuggingPriority(.defaultLow, for: .vertical)
        _interactionStackView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        [_tickerView, _progressBarView, infoContainerView].forEach {
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
        }
    }
    
    private func setupInfoStackView() {
        // Container visuel avec coins arrondis et fond sombre
        infoContainerView.backgroundColor = UIColor(white: 0.1, alpha: 0.4)
        infoContainerView.layer.cornerRadius = 16
        infoContainerView.layer.masksToBounds = true

        // Stack verticale interne
        infoStack.axis = .vertical
        infoStack.spacing = 8
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoStack.addArrangedSubview(_descriptionView)
        infoStack.addArrangedSubview(_musicView)

        infoContainerView.addSubview(infoStack)
        infoStack.leadingAnchor.constraint(equalTo: infoContainerView.layoutMarginsGuide.leadingAnchor, constant: 2).isActive = true
        infoStack.trailingAnchor.constraint(equalTo: infoContainerView.layoutMarginsGuide.trailingAnchor, constant: -2).isActive = true
        infoStack.topAnchor.constraint(equalTo: infoContainerView.layoutMarginsGuide.topAnchor).isActive = true
        infoStack.bottomAnchor.constraint(equalTo: infoContainerView.layoutMarginsGuide.bottomAnchor).isActive = true
    }
    
    private func setupProgressBar() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProgressTap))
        
        _progressBarView.translatesAutoresizingMaskIntoConstraints = false
        _progressBarView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        _progressBarView.preservesSuperviewLayoutMargins = false
        _progressBarView.addGestureRecognizer(tap)
    }
    
    private func setupInteraction() {
        let leftZone = UIView()
        let rightZone = UIView()
        
        let leftTap = UITapGestureRecognizer(target: self, action: #selector(handleLeftInteractionTap))
        let rightTap = UITapGestureRecognizer(target: self, action: #selector(handleRightInteractionTap))
        
        [leftZone, rightZone].forEach {
            $0.isUserInteractionEnabled = true
        }
        
        leftZone.addGestureRecognizer(leftTap)
        rightZone.addGestureRecognizer(rightTap)
        
        _interactionStackView.axis = .horizontal
        _interactionStackView.distribution = .fillEqually
        _interactionStackView.alignment = .fill
        _interactionStackView.spacing = 0
        _interactionStackView.translatesAutoresizingMaskIntoConstraints = false
        
        _interactionStackView.addArrangedSubview(leftZone)
        _interactionStackView.addArrangedSubview(rightZone)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            _gradientAnchorGuide.topAnchor.constraint(equalTo: self.topAnchor, constant: 40),
            _gradientAnchorGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
            _gradientAnchorGuide.widthAnchor.constraint(equalToConstant: 0),
            _gradientAnchorGuide.heightAnchor.constraint(equalToConstant: 0),
        ])
    }
    
    private func wrapWithPadding(_ view: UIView, left: CGFloat = 16, right: CGFloat = 16) -> UIStackView {
        let leftSpacer = UIView()
        leftSpacer.translatesAutoresizingMaskIntoConstraints = false
        leftSpacer.widthAnchor.constraint(equalToConstant: left).isActive = true

        let rightSpacer = UIView()
        rightSpacer.translatesAutoresizingMaskIntoConstraints = false
        rightSpacer.widthAnchor.constraint(equalToConstant: right).isActive = true

        let hStack = UIStackView(arrangedSubviews: [leftSpacer, view, rightSpacer])
        hStack.axis = .horizontal
        hStack.spacing = 0
        hStack.alignment = .fill
        hStack.distribution = .fill
        hStack.translatesAutoresizingMaskIntoConstraints = false
        return hStack
    }
    
    // MARK: - Public API
    
    /// Subviews
    var interactionStackView: UIStackView { _interactionStackView }
    var tickerView: OverlayTickerView { _tickerView }
    var progressBarView: OverlayProgressBarView { _progressBarView }
    var descriptionStackView: OverlayDescriptionView { _descriptionView }
    var musicStackView: OverlayMusicView { _musicView }
    var gradientAnchorGuide: UILayoutGuide { _gradientAnchorGuide }
    
    var isInteractable: Bool {
        !isHidden && isUserInteractionEnabled  && isContentVisible
    }
    
    var addSongButton: UIButton {
        return _musicView.addSongButton
    }
    
    /// Callback
    var onTapInteractionLeft: (() -> Void)?
    var onTapInteractionRight: (() -> Void)?
    
    var onTickerTap: (() -> Void)? {
        get { _tickerView.onTap }
        set { _tickerView.onTap = newValue }
    }
    
    func configure(with post: Post.Model) {
        _descriptionView.descriptionLabel.text = post.text
        _descriptionView.metaLabel.text = "2m ago ∙ Guangzhou, China"
        
        _musicView.musicLabel.text = "♫ 侯波(江南版)"
        _musicView.artistLabel.text = "傲寒同学"
        
        if let avatarURL = post.author.avatarURL {
            _musicView.musicCoverImageView.loadImage(from: avatarURL)
        } else {
            _musicView.musicCoverImageView.image = UIImage(systemName: "opticaldisc.fill")
            _musicView.musicCoverImageView.tintColor = .white.withAlphaComponent(0.5)
        }
        
        if !post.comments.isEmpty {
            _tickerView.isHidden = false
            _tickerView.configure(with: post)
        } else {
            _tickerView.isHidden = true
        }
        
        if case let .gallery(items) = post.content {
            updateProgressBarPresence(show: true)
            _progressBarView.configureSegments(count: items.count, currentIndex: 0)
        } else {
            updateProgressBarPresence(show: false)
        }
    }
    
    func setContentVisible(_ visible: Bool, animated: Bool = true) {
        guard visible != isContentVisible else { return }
        isContentVisible = visible
        let targetAlpha: CGFloat = visible ? 1 : 0
        
        let animation = {
            self.stackView.alpha = targetAlpha
        }
        let completion: (Bool) -> Void = { _ in
            self.stackView.isHidden = !visible
            self.isUserInteractionEnabled = visible
        }
        
        if animated {
            if visible {
                stackView.isHidden = false
                self.isUserInteractionEnabled = true
            }
            UIView.animate(withDuration: 0.2, animations: animation, completion: completion)
        } else {
            stackView.alpha = targetAlpha
            stackView.isHidden = !visible
            self.isUserInteractionEnabled = visible
        }
    }
    
    func updateProgressBarPresence(show: Bool) {
        _progressBarView.isHidden = !show
    }
    
    /// Gestures
    @objc private func handleProgressTap() {
        _progressBarView.activateFocusIfNeeded()
    }
    
    @objc private func handleLeftInteractionTap() {
        _progressBarView.activateFocusIfNeeded()
        _progressBarView.refreshFocusTimerIfNeeded()
        onTapInteractionLeft?()
    }
    
    @objc private func handleRightInteractionTap() {
        _progressBarView.activateFocusIfNeeded()
        _progressBarView.refreshFocusTimerIfNeeded()
        onTapInteractionRight?()
    }
}
