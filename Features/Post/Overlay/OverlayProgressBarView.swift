//
//  OverlayBodyProgressBarView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 18/05/2025.
//

import UIKit

final class OverlayProgressBarView: UIView {

    // MARK: - Subviews

    private let indexLabel = UILabel()

    // MARK: - Configuration

    private let viewHeight: CGFloat = 16
    private let segmentSpacing: CGFloat = 4
    private let segmentHeight: CGFloat = 4
    private let activeWidthMultiplier: CGFloat = 2.0

    // MARK: - State

    private var segmentCount: Int = 0
    private var activeIndex: Int = 0
    private var segmentViews: [UIView] = []
    private var dismissTimer: Timer?
    private var labelTargetFrame: CGRect = .zero
    private var isDismissingFocus = false
    
    private var isFocusedLayout = false {
        didSet { resetDismissTimerIfNeeded() }
    }
    
    // MARK: - Constraint
    private var labelCenterXConstraint: NSLayoutConstraint?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: viewHeight)
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .clear
        preservesSuperviewLayoutMargins = false

        setupIndexLabel()
    }
    
    private func setupIndexLabel() {
        indexLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        indexLabel.textColor = .white
        indexLabel.textAlignment = .center
        indexLabel.backgroundColor = .accent
        indexLabel.layer.cornerRadius = viewHeight / 2
        indexLabel.clipsToBounds = true
        indexLabel.alpha = 0
        indexLabel.isHidden = true
        indexLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(indexLabel)
        bringSubviewToFront(indexLabel)
    }

    private func resetDismissTimerIfNeeded() {
        dismissTimer?.invalidate()

        guard isFocusedLayout else { return }

        dismissTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.dismissFocusIfNeeded()
        }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, !segmentViews.isEmpty else { return }

        let y = (bounds.height - segmentHeight) / 2
        let leftPadding = layoutMargins.left
        let rightPadding = layoutMargins.right
        var currentX: CGFloat = leftPadding
        var activeFrame: CGRect = .zero

        let isFocus = isFocusedLayout
        let lower = max(0, activeIndex - 2)
        let upper = min(segmentViews.count - 1, activeIndex + 2)
        let visibleIndices: Set<Int> = isFocus ? Set(lower...upper) : Set(0..<segmentViews.count)
        let segmentsToLayout = segmentViews.enumerated().filter { visibleIndices.contains($0.offset) }
        let visibleCount = CGFloat(segmentsToLayout.count)
        let totalSpacing = CGFloat(max(Int(visibleCount) - 1, 0)) * segmentSpacing
        let totalAvailableWidth = bounds.width - leftPadding - rightPadding - totalSpacing

        if isFocus {
            let activeWidth = totalAvailableWidth * 0.8
            let otherCount = max(visibleCount - 1, 1)
            let otherWidth = (totalAvailableWidth * 0.2) / otherCount

            for (i, segment) in segmentViews.enumerated() {
                let isInWindow = visibleIndices.contains(i)
                let isActive = (i == activeIndex)
                let width = isActive ? activeWidth : (isInWindow ? otherWidth : 0)

                segment.alpha = isInWindow ? 1 : 0
                segment.frame = CGRect(x: currentX, y: y, width: width, height: segmentHeight)
                segment.layer.cornerRadius = segmentHeight / 2

                if isActive { activeFrame = segment.frame }
                if isInWindow { currentX += width + segmentSpacing }
            }
        } else {
            let weightSum = CGFloat(segmentViews.count - 1) + activeWidthMultiplier
            let unitWidth = totalAvailableWidth / weightSum

            for (i, segment) in segmentViews.enumerated() {
                let isActive = (i == activeIndex)
                let width = isActive ? unitWidth * activeWidthMultiplier : unitWidth

                segment.frame = CGRect(x: currentX, y: y, width: width, height: segmentHeight)
                segment.layer.cornerRadius = segmentHeight / 2
                segment.alpha = 1
                if isActive { activeFrame = segment.frame }
                currentX += width + segmentSpacing
            }
        }

        updateIndexLabelFrame(activeFrame: activeFrame)
    }

    private func updateIndexLabelFrame(activeFrame: CGRect) {
        let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: viewHeight)
        let textRect = indexLabel.sizeThatFits(maxSize)
        let labelWidth = ceil(textRect.width) + 12
        let labelHeight = viewHeight

        labelTargetFrame = CGRect(
            x: activeFrame.midX - labelWidth / 2,
            y: activeFrame.midY - labelHeight / 2,
            width: labelWidth,
            height: labelHeight
        )

        if isFocusedLayout && !isDismissingFocus {
            indexLabel.frame = labelTargetFrame
        }
        
        if segmentViews.indices.contains(activeIndex) {
                let segment = segmentViews[activeIndex]
                // Enlève la contrainte précédente s'il y en a une
                labelCenterXConstraint?.isActive = false

                // Ajoute une contrainte pour centrer horizontalement le label sur le segment actif
                labelCenterXConstraint = indexLabel.centerXAnchor.constraint(equalTo: segment.centerXAnchor)
                labelCenterXConstraint?.isActive = true

                // Place verticalement le label comme tu veux (par exemple sur self)
                indexLabel.center.y = segment.center.y

                // Mets à jour la taille manuellement, car tu veux un width custom
                let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: viewHeight)
                let textRect = indexLabel.sizeThatFits(maxSize)
                let labelWidth = ceil(textRect.width) + 12
                let labelHeight = viewHeight
                indexLabel.bounds = CGRect(x: 0, y: 0, width: labelWidth, height: labelHeight)
            }
    }

    // MARK: - Interaction

    @objc private func handleTap() {
        guard !isDismissingFocus else { return }

        if isFocusedLayout {
            dismissFocusIfNeeded()
        } else {
            isFocusedLayout = true
            setNeedsLayout()

            updateIndexLabel(current: activeIndex + 1, total: segmentCount)
            indexLabel.alpha = 0
            indexLabel.frame = labelTargetFrame
            indexLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
            indexLabel.isHidden = false

            UIView.animate(
                withDuration: 0.55,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.4,
                options: [.curveEaseOut],
                animations: {
                    self.indexLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.indexLabel.alpha = 1
                },
                completion: nil
            )
        }
    }
    
    @objc func activateFocusIfNeeded() {
        if !isFocusedLayout {
            handleTap()
        }
    }
    
    func updateIndexLabel(current: Int, total: Int) {
        let currentStr = "\(current)"
        let totalStr = "\(total)"

        let attributed = NSMutableAttributedString()

        attributed.append(NSAttributedString(
            string: currentStr,
            attributes: [
                .font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption2).pointSize, weight: .bold),
                .foregroundColor: UIColor.white
            ]
        ))

        attributed.append(NSAttributedString(
            string: " / ",
            attributes: [
                .font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption2).pointSize, weight: .regular),
                .foregroundColor: UIColor.white.withAlphaComponent(0.7)
            ]
        ))

        attributed.append(NSAttributedString(
            string: totalStr,
            attributes: [
                .font:  UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption2).pointSize, weight: .regular),
                .foregroundColor: UIColor.white.withAlphaComponent(0.7)
            ]
        ))

        indexLabel.attributedText = attributed
    }
    
    func refreshFocusTimerIfNeeded() {
        guard isFocusedLayout else { return }
        resetDismissTimerIfNeeded()
    }
    
    // MARK: - Public API

    func configureSegments(count: Int, currentIndex: Int = 0) {
        segmentViews.forEach { $0.removeFromSuperview() }
        segmentViews = []
        segmentCount = count
        activeIndex = currentIndex
        isFocusedLayout = false
        dismissTimer?.invalidate()

        guard count > 0 else { return }

        for i in 0..<count {
            let segment = UIView()
            segment.backgroundColor = (i == currentIndex)
                ? .accent.withAlphaComponent(0.6)
                : UIColor.white.withAlphaComponent(0.4)
            segment.layer.cornerRadius = segmentHeight / 2
            segment.clipsToBounds = true
            segment.transform = (i == currentIndex) ? CGAffineTransform(scaleX: 1.08, y: 1.0) : .identity
            addSubview(segment)
            segmentViews.append(segment)
        }

        updateIndexLabel(current: activeIndex + 1, total: segmentCount)
        indexLabel.isHidden = true
        indexLabel.alpha = 0
        bringSubviewToFront(indexLabel)
        setNeedsLayout()
    }

    func updateProgress(to index: Int) {
        guard index >= 0, index < segmentCount, index != activeIndex else { return }

        let previousIndex = activeIndex
        activeIndex = index

        if !isDismissingFocus {
            updateIndexLabel(current: activeIndex + 1, total: segmentCount)
        }

        UIView.transition(with: segmentViews[index], duration: 0.15, options: .transitionCrossDissolve) {
            self.segmentViews[index].backgroundColor = .accent.withAlphaComponent(0.6)
        }

        UIView.transition(with: segmentViews[previousIndex], duration: 0.15, options: .transitionCrossDissolve) {
            self.segmentViews[previousIndex].backgroundColor = UIColor.white.withAlphaComponent(0.4)
        }

        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.4, options: [.curveEaseInOut]) {
            self.segmentViews[previousIndex].transform = .identity
            self.segmentViews[index].transform = CGAffineTransform(scaleX: 1.08, y: 1.0)
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    func dismissFocusIfNeeded() {
        guard !isDismissingFocus else { return }

        isDismissingFocus = true
        dismissTimer?.invalidate()
        dismissTimer = nil

        UIView.animate(
            withDuration: 0.55,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.3,
            options: [.curveEaseInOut],
            animations: {
                self.isFocusedLayout = false
                self.setNeedsLayout()
                self.layoutIfNeeded()
                self.indexLabel.alpha = 0
                self.indexLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            },
            completion: { _ in
                self.indexLabel.transform = .identity
                self.indexLabel.isHidden = true
                self.isDismissingFocus = false
            }
        )
    }
    
    private func animateLayoutChange(_ changes: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.55,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.45,
            options: [.curveEaseInOut, .beginFromCurrentState],
            animations: {
                changes()
                self.layoutIfNeeded()
            }
        )
    }
    
    func copyState(from source: OverlayProgressBarView) {
        self.configureSegments(count: source.segmentCount, currentIndex: source.activeIndex)
    }
}

