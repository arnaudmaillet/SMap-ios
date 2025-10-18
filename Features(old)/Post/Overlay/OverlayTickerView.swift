//
//  OverlayCommentView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 01/05/2025.
//


import UIKit

final class OverlayTickerView: UIView {

    // MARK: - UI Components

    private let stackView = UIStackView()
    private let overlayContainer = UIView()
    private let blurEffectView = UIVisualEffectView(effect: nil)
    private var blurHeightConstraint: NSLayoutConstraint?

    // MARK: - Animation State

    private var displayLinkWrappers: [CADisplayLinkWrapper] = []
    private var animatedTracks: [(track: UIView, speed: CGFloat, panOffset: CGFloat)] = []
    private let minSpeed: CGFloat = 10.0
    private let maxSpeed: CGFloat = 20.0
    private var previousPanTranslation: CGFloat = 0
    private let minimumInertiaVelocity: CGFloat = 300
    private var cumulativeScrollDistance: CGFloat = 0
    private var isPanningManually = false

    // MARK: - Inertia Handling

    private struct Inertia {
        var velocity: CGFloat
        var displayLink: CADisplayLink?
    }

    private var inertia: Inertia?

    // MARK: - Public Properties
    
    var onTap: (() -> Void)?

    var textColor: UIColor = .black.withAlphaComponent(0.6)

    var commentLines: [[Post.Comment]] = [] {
        didSet {
            setupLines()
        }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGesture()
        setupStackView()
        setupOverlayContainer()
        setupFadeMask()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        (layer.mask as? CAGradientLayer)?.frame = bounds
    }

    // MARK: - Setup

    private func setupGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }

    private func setupStackView() {
        // Add blur behind the stackView, anchored to bottom
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.alpha = 0
        blurEffectView.isUserInteractionEnabled = false
        addSubview(blurEffectView)

        // StackView setup
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        addSubview(stackView)

        NSLayoutConstraint.activate([
            blurEffectView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        blurHeightConstraint = blurEffectView.heightAnchor.constraint(equalToConstant: 0)
        blurHeightConstraint?.isActive = true
    }

    private func setupOverlayContainer() {
        addSubview(overlayContainer)
        overlayContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayContainer.topAnchor.constraint(equalTo: topAnchor),
            overlayContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        overlayContainer.isUserInteractionEnabled = false
    }

    private func setupFadeMask() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 0.1, 0.9, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = bounds
        layer.mask = gradientLayer
    }

    // MARK: - Configuration

    func configure(with post: Post.Model) {
        guard !post.comments.isEmpty else {
            commentLines = []
            return
        }

        let total = post.comments.count
        let lines: Int

        switch total {
        case 0..<5: lines = 1
        case 5..<10: lines = 2
        default: lines = 3
        }

        let commentsPerLine = Int(ceil(Double(total) / Double(lines)))
        var grouped: [[Post.Comment]] = []

        for i in 0..<lines {
            let start = i * commentsPerLine
            let end = min(start + commentsPerLine, total)
            grouped.append(Array(post.comments[start..<end]))
        }

        if let isDark = post.mainRenderable?.thumbnailImage?.isDark(), isDark {
            textColor = .white.withAlphaComponent(0.8)
        }

        commentLines = grouped
    }

    // MARK: - Rendering

    private func setupLines() {
        animatedTracks.removeAll()
        displayLinkWrappers.forEach { $0.stop() }
        displayLinkWrappers.removeAll()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let linesToRender: [[Post.Comment]]
        switch commentLines.count {
        case 1: linesToRender = [commentLines[0]]
        case 2: linesToRender = [commentLines[0], commentLines[1]]
        default: linesToRender = commentLines
        }
        let totalLines = linesToRender.count
        let uniqueSpeeds = generateDistinctSpeeds(count: totalLines, min: minSpeed, max: maxSpeed)

        for (i, line) in linesToRender.enumerated() {
            let container = UIView()
            container.clipsToBounds = true
            stackView.addArrangedSubview(container)

            guard !line.isEmpty else { continue }

            let track = UIView()
            container.addSubview(track)
            track.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                track.topAnchor.constraint(equalTo: container.topAnchor),
                track.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])

            let baseText = line.map { "\($0.author.username): \($0.text)" }.joined(separator: "     •     ")
            layoutIfNeeded()

            let targetWidth = bounds.width * 2
            let estimatedWidth = createLabel(with: baseText).intrinsicContentSize.width
            let repeatCount = estimatedWidth < targetWidth ? Int(ceil(targetWidth / estimatedWidth)) : 1
            let finalText = Array(repeating: baseText, count: repeatCount).joined(separator: "     •     ")

            let label1 = createLabel(with: finalText)
            let label2 = createLabel(with: finalText)
            track.addSubview(label1)
            track.addSubview(label2)

            NSLayoutConstraint.activate([
                label1.topAnchor.constraint(equalTo: track.topAnchor),
                label1.bottomAnchor.constraint(equalTo: track.bottomAnchor),
                label1.leadingAnchor.constraint(equalTo: track.leadingAnchor),

                label2.topAnchor.constraint(equalTo: track.topAnchor),
                label2.bottomAnchor.constraint(equalTo: track.bottomAnchor),
                label2.leadingAnchor.constraint(equalTo: label1.trailingAnchor),
                label2.trailingAnchor.constraint(equalTo: track.trailingAnchor)
            ])

            layoutIfNeeded()
            let labelWidth = label1.intrinsicContentSize.width
            track.frame = CGRect(x: 0, y: 0, width: labelWidth * 2, height: container.bounds.height)
            let speed = uniqueSpeeds[i]
            let displayLinkWrapper = CADisplayLinkWrapper()

            displayLinkWrapper.callback = { [weak self, weak track] duration in
                guard let self = self, let track = track else { return }
                guard !self.isPanningManually else { return }

                let dx = speed * CGFloat(duration)
                let tx = track.transform.tx - dx
                let labelWidth = track.bounds.width / 2
                var wrappedTx = tx.truncatingRemainder(dividingBy: labelWidth)
                if wrappedTx > 0 { wrappedTx -= labelWidth }
                track.transform = CGAffineTransform(translationX: wrappedTx, y: 0)
            }

            animatedTracks.append((track: track, speed: speed, panOffset: 0))
            displayLinkWrapper.start()
            displayLinkWrappers.append(displayLinkWrapper)
        }

        // 💡 Met à jour la hauteur du blur en fonction du nombre de lignes visibles
        layoutIfNeeded()

        let visibleLineCount = commentLines.count
        let totalLineCount = stackView.arrangedSubviews.count
        guard totalLineCount > 0 else { return }

        // 👉 Calcul de la hauteur utile sans les marges
        let availableHeight = stackView.frame.height
        let lineHeight = availableHeight / CGFloat(totalLineCount)

        // 👉 Application correcte à la hauteur du blur
        blurHeightConstraint?.constant = CGFloat(visibleLineCount) * lineHeight
    }

    private func createLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.lineBreakMode = .byClipping
        return label
    }
    
    // MARK: - Animation Func
    
    private func generateDistinctSpeeds(count: Int, min: CGFloat, max: CGFloat) -> [CGFloat] {
        guard count > 1 else { return [CGFloat.random(in: min...max)] }

        let step = (max - min) / CGFloat(count - 1)
        var speeds = (0..<count).map { min + CGFloat($0) * step }

        speeds.shuffle()

        return speeds
    }

    // MARK: - Gesture Handling

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self).x
        let delta = translation - previousPanTranslation
        previousPanTranslation = translation

        switch gesture.state {
        case .began:
            isPanningManually = true
            cumulativeScrollDistance = 0
            inertia?.displayLink?.invalidate()
            inertia = nil

        case .changed:
            cumulativeScrollDistance += abs(delta)

            let maxCumulative: CGFloat = 120
            let progress = min(cumulativeScrollDistance / maxCumulative, 1.0)
            let easedAlpha = pow(progress, 0.7)

            if blurEffectView.effect == nil {
                blurEffectView.effect = UIBlurEffect(style: .light)
            }
            blurEffectView.alpha = easedAlpha

            for i in 0..<animatedTracks.count {
                let animated = animatedTracks[i]
                let offset = delta * animated.speed * 0.05
                let tx = animated.track.transform.tx + offset
                let labelWidth = animated.track.bounds.width / 2
                var wrappedTx = tx.truncatingRemainder(dividingBy: labelWidth)
                if wrappedTx > 0 { wrappedTx -= labelWidth }
                animated.track.transform = CGAffineTransform(translationX: wrappedTx, y: 0)
            }

        case .ended, .cancelled, .failed:
            isPanningManually = false
            previousPanTranslation = 0
            let velocity = gesture.velocity(in: self).x

            if abs(velocity) < minimumInertiaVelocity {
                // Pas d'inertie → fade out immédiat à la fin
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) {
                    self.blurEffectView.alpha = 0
                } completion: { _ in
                    self.blurEffectView.effect = nil
                }
                return
            }

            startInertia(with: velocity)

        default:
            break
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }

        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
                self.transform = .identity
            } completion: { _ in
                self.onTap?()
            }
        }
    }

    // MARK: - Inertia Scrolling

    private func startInertia(with initialVelocity: CGFloat) {
        inertia?.displayLink?.invalidate()
        
        if abs(initialVelocity) < minimumInertiaVelocity {
            // 🚫 Pas assez de vitesse → pas d’inertie → fade out immédiat dans handleInertia
            self.inertia = Inertia(velocity: initialVelocity, displayLink: nil)
            handleInertia(nil)
            return
        }

        let link = CADisplayLink(target: self, selector: #selector(handleInertia))
        link.add(to: .main, forMode: .common)
        self.inertia = Inertia(velocity: initialVelocity, displayLink: link)
    }

    @objc private func handleInertia(_ link: CADisplayLink?) {
        guard var inertia = inertia else {
            link?.invalidate()
            return
        }

        let duration = CGFloat(link?.duration ?? (1.0 / 60.0))
        let delta = inertia.velocity * duration

        for animated in animatedTracks {
            let offset = delta * animated.speed * 0.05
            let tx = animated.track.transform.tx + offset
            let labelWidth = animated.track.bounds.width / 2
            var wrappedTx = tx.truncatingRemainder(dividingBy: labelWidth)
            if wrappedTx > 0 { wrappedTx -= labelWidth }
            animated.track.transform = CGAffineTransform(translationX: wrappedTx, y: 0)
        }

        let normalizedVelocity = min(max(abs(inertia.velocity) / 1000.0, 0.0), 1.0)
        let easedAlpha = 1.0 - pow(1.0 - normalizedVelocity, 2.0)
        blurEffectView.alpha = easedAlpha

        inertia.velocity *= 0.95

        if abs(inertia.velocity) < 5.0 {
            link?.invalidate()
            self.inertia = nil

            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) {
                self.blurEffectView.alpha = 0
            } completion: { _ in
                self.blurEffectView.effect = nil
            }
        } else {
            self.inertia?.velocity = inertia.velocity
        }
    }
}

// MARK: - CADisplayLinkWrapper

/// Lightweight wrapper around CADisplayLink to simplify callback-based animation.
private class CADisplayLinkWrapper {
    var link: CADisplayLink!
    var callback: ((CFTimeInterval) -> Void)?
    private var isRunning = false

    init() {
        link = CADisplayLink(target: self, selector: #selector(tick))
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        link.add(to: .main, forMode: .common)
    }

    func pause() {
        link.isPaused = true
    }

    func resume() {
        link.isPaused = false
    }

    func stop() {
        isRunning = false
        link.invalidate()
    }

    @objc private func tick(_ sender: CADisplayLink) {
        guard !link.isPaused else { return }
        callback?(sender.duration)
    }

    deinit {
        stop()
    }
}
