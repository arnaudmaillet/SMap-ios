//
//  OverlayCommentView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 01/05/2025.
//

import UIKit

final class OverlayCommentView: UIView {

    // MARK: - UI Components

    private let stackView = UIStackView()
    private let overlayContainer = UIView()

    // MARK: - Animation State

    private var displayLinkWrappers: [CADisplayLinkWrapper] = []
    private var animatedTracks: [(track: UIView, speed: CGFloat)] = []
    private let minSpeed: CGFloat = 10.0
    private let maxSpeed: CGFloat = 20.0
    private var previousPanTranslation: CGFloat = 0

    // MARK: - Inertia Handling

    private struct Inertia {
        var velocity: CGFloat
        var displayLink: CADisplayLink?
    }

    private var inertia: Inertia?

    // MARK: - Public Properties

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

    // MARK: - Setup Methods

    private func setupGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
    }

    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
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

    /// Configures the comment view using a post model.
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

    // MARK: - Comment Line Rendering

    private func setupLines() {
        animatedTracks.removeAll()
        displayLinkWrappers.forEach { $0.stop() }
        displayLinkWrappers.removeAll()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let linesToRender: [[Post.Comment]]
        switch commentLines.count {
        case 1: linesToRender = [[], [], commentLines[0]]
        case 2: linesToRender = [[], commentLines[0], commentLines[1]]
        default: linesToRender = commentLines
        }

        for line in linesToRender {
            let container = UIView()
            container.clipsToBounds = true
            stackView.addArrangedSubview(container)

            guard !line.isEmpty else { continue }

            let track = UIView()
            container.addSubview(track)
            track.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                track.topAnchor.constraint(equalTo: container.topAnchor),
                track.bottomAnchor.constraint(equalTo: container.bottomAnchor),
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

            let speed = CGFloat.random(in: minSpeed...maxSpeed)
            let displayLinkWrapper = CADisplayLinkWrapper()

            displayLinkWrapper.callback = { [weak track] duration in
                guard let track else { return }
                let dx = speed * CGFloat(duration)
                var tx = track.transform.tx - dx
                tx = tx.truncatingRemainder(dividingBy: labelWidth)
                if tx > 0 { tx -= labelWidth }
                track.transform = CGAffineTransform(translationX: tx, y: 0)
            }

            animatedTracks.append((track, speed))
            displayLinkWrapper.start()
            displayLinkWrappers.append(displayLinkWrapper)
        }
    }

    private func createLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.lineBreakMode = .byClipping
        return label
    }

    // MARK: - Gesture Handling

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self).x
        let delta = translation - previousPanTranslation
        previousPanTranslation = translation

        switch gesture.state {
        case .began:
            inertia?.displayLink?.invalidate()
            inertia = nil
            displayLinkWrappers.forEach { $0.pause() }

        case .changed:
            for animated in animatedTracks {
                let offset = delta * animated.speed * 0.05
                let tx = animated.track.transform.tx + offset
                let labelWidth = animated.track.bounds.width / 2
                var wrappedTx = tx.truncatingRemainder(dividingBy: labelWidth)
                if wrappedTx > 0 { wrappedTx -= labelWidth }
                animated.track.transform = CGAffineTransform(translationX: wrappedTx, y: 0)
            }

        case .ended, .cancelled, .failed:
            let velocity = gesture.velocity(in: self).x
            previousPanTranslation = 0
            startInertia(with: velocity)

        default:
            break
        }
    }

    // MARK: - Inertia Scrolling

    private func startInertia(with initialVelocity: CGFloat) {
        inertia?.displayLink?.invalidate()
        inertia = Inertia(velocity: initialVelocity, displayLink: nil)

        let link = CADisplayLink(target: self, selector: #selector(handleInertia))
        link.add(to: .main, forMode: .common)
        inertia?.displayLink = link
    }

    @objc private func handleInertia(_ link: CADisplayLink) {
        guard var inertia = inertia else {
            link.invalidate()
            return
        }

        let delta = inertia.velocity * CGFloat(link.duration)

        for animated in animatedTracks {
            let offset = delta * animated.speed * 0.05
            let tx = animated.track.transform.tx + offset
            let labelWidth = animated.track.bounds.width / 2
            var wrappedTx = tx.truncatingRemainder(dividingBy: labelWidth)
            if wrappedTx > 0 { wrappedTx -= labelWidth }
            animated.track.transform = CGAffineTransform(translationX: wrappedTx, y: 0)
        }

        inertia.velocity *= 0.95

        if abs(inertia.velocity) < 5.0 {
            link.invalidate()
            self.inertia = nil
            displayLinkWrappers.forEach { $0.resume() }
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
