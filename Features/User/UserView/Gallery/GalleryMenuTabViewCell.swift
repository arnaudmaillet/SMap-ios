//
//  GalleryHeaderViewCell.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 03/08/2025.
//

import UIKit

extension Gallery.MenuTabViewCell {
    static let reuseIdentifier = "Gallery.TabMenuViewCell"
}

extension Gallery {
    final class MenuTabViewCell: UICollectionReusableView {
        private let categoryTabs = Gallery.MenuTabView()
        private let sortPills = Gallery.HeaderPillsView()
        private let stack = UIStackView()
        
        var onCategorySelected: ((Int) -> Void)?
        var onSortSelected: ((Int) -> Void)?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        required init?(coder: NSCoder) { fatalError() }
        
        private func setupView() {
            backgroundColor = .clear
            stack.axis = .vertical
            stack.spacing = 0
            addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: topAnchor),
                stack.leadingAnchor.constraint(equalTo: leadingAnchor),
                stack.trailingAnchor.constraint(equalTo: trailingAnchor),
                stack.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            stack.addArrangedSubview(categoryTabs)
            stack.addArrangedSubview(sortPills)
        }
        
        func configure(categories: [String], selectedCategory: Int, sorts: [String], selectedSort: Int) {
            categoryTabs.configure(with: categories, selectedIndex: selectedCategory)
            categoryTabs.onTabSelected = { [weak self] index in
                self?.onCategorySelected?(index)
            }
            sortPills.configure(options: sorts, selectedIndex: selectedSort)
            sortPills.onSortSelected = { [weak self] index in
                self?.onSortSelected?(index)
            }
        }
    }
    
    
    // === CategoryTabsHeader avec interpolation fluide ===
    final class MenuTabView: UICollectionReusableView {
        private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        private let stack = UIStackView()
        private var buttons: [UIButton] = []
        private let underline = UIView()
        private let bottomSeparator = UIView()
        private var selectedIndex: Int = 0
        var onTabSelected: ((Int) -> Void)?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        required init?(coder: NSCoder) { fatalError() }
        
        private func setupView() {
            // --- Blur en arrière-plan ---
            addSubview(blurView)
            blurView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                blurView.topAnchor.constraint(equalTo: topAnchor),
                blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
                blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
                blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            
            // --- Stack des boutons ---
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.alignment = .center
            addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: topAnchor),
                stack.leadingAnchor.constraint(equalTo: leadingAnchor),
                stack.trailingAnchor.constraint(equalTo: trailingAnchor),
                stack.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            
            // --- Underline ---
            underline.backgroundColor = .label
            addSubview(underline)
            
            // --- Séparateur bas ---
            bottomSeparator.backgroundColor = UIColor.systemGray4
            addSubview(bottomSeparator)
            bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bottomSeparator.heightAnchor.constraint(equalToConstant: 1),
                bottomSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
                bottomSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
                bottomSeparator.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
        
        func configure(with iconNames: [String], selectedIndex: Int) {
            stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            buttons.removeAll()
            
            for (index, iconName) in iconNames.enumerated() {
                let btn = UIButton(type: .system)
                let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
                btn.setImage(UIImage(systemName: iconName, withConfiguration: config), for: .normal)
                btn.tintColor = index == selectedIndex ? .label : .secondaryLabel
                btn.contentVerticalAlignment = .center
                btn.contentHorizontalAlignment = .center
                btn.tag = index
                
                btn.translatesAutoresizingMaskIntoConstraints = false
                btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
                
                btn.addAction(UIAction { [weak self] _ in self?.selectTab(index) }, for: .touchUpInside)
                stack.addArrangedSubview(btn)
                buttons.append(btn)
            }
            
            self.selectedIndex = selectedIndex
            layoutIfNeeded()
            positionUnderline(animated: false)
        }
        
        func selectTab(_ index: Int) {
            selectedIndex = index
            for (i, btn) in buttons.enumerated() {
                btn.tintColor = i == index ? .label : .secondaryLabel
            }
            positionUnderline(animated: true)
            onTabSelected?(index)
        }
        
        func updateUnderlinePosition(progress: CGFloat) {
            guard buttons.count > 1 else { return }
            let totalWidth = buttons[0].frame.width
            let x = progress * totalWidth
            var frame = underline.frame
            frame.origin.x = x
            underline.frame = frame
        }
        
        private func positionUnderline(animated: Bool) {
            guard !buttons.isEmpty else { return }
            let selectedButton = buttons[selectedIndex]
            let underlineHeight: CGFloat = 2
            let underlineY = bounds.height - underlineHeight
            let underlineFrame = CGRect(x: selectedButton.frame.minX,
                                        y: underlineY,
                                        width: selectedButton.frame.width,
                                        height: underlineHeight)
            if animated {
                UIView.animate(withDuration: 0.25) { self.underline.frame = underlineFrame }
            } else {
                underline.frame = underlineFrame
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            positionUnderline(animated: false)
        }
    }
    
    final class HeaderPillsView: UIView {
        private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        private let gradientMask = CAGradientLayer()
        private let scrollView = UIScrollView()
        private let stack = UIStackView()
        private var buttons: [UIButton] = []
        private var animators: [Int: UIViewPropertyAnimator] = [:]
        private var selectedIndex: Int = 0
        
        var onSortSelected: ((Int) -> Void)?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        required init?(coder: NSCoder) { fatalError() }
        
        private func setupView() {
            addSubview(blurView)
            blurView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                blurView.topAnchor.constraint(equalTo: topAnchor),
                blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
                blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
                blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            
            gradientMask.colors = [
                UIColor.black.cgColor,
                UIColor.black.withAlphaComponent(0.5).cgColor,
                UIColor.black.withAlphaComponent(0.0).cgColor
            ]
            gradientMask.locations = [0.0, 0.5, 1.0]
            gradientMask.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientMask.endPoint = CGPoint(x: 0.5, y: 1.0)
            blurView.layer.mask = gradientMask
            
            scrollView.showsHorizontalScrollIndicator = false
            addSubview(scrollView)
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
                scrollView.heightAnchor.constraint(equalToConstant: 44)
            ])
            
            stack.axis = .horizontal
            stack.spacing = 8
            stack.alignment = .center
            scrollView.addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: scrollView.topAnchor),
                stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
                stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12),
                stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                stack.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            ])
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            gradientMask.frame = bounds
        }
        
        private func makeButton(title: String, isSelected: Bool) -> UIButton {
            var config = UIButton.Configuration.filled()
            config.title = title
            config.baseBackgroundColor = isSelected ? .accent : .systemGray5
            config.baseForegroundColor = isSelected ? .white : .label
            config.titleLineBreakMode = .byTruncatingTail
            config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)
            
            let btn = UIButton(configuration: config)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.heightAnchor.constraint(equalToConstant: 32).isActive = true
            btn.layer.masksToBounds = true
            btn.layer.cornerRadius = isSelected ? 16 : 6
            return btn
        }
        
        func configure(options: [String], selectedIndex: Int = 0) {
            stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            buttons.removeAll()
            animators.removeAll()
            
            for (index, title) in options.enumerated() {
                let isSelected = (index == selectedIndex)
                let btn = makeButton(title: title, isSelected: isSelected)
                btn.tag = index
                btn.addAction(UIAction { [weak self] _ in self?.select(index) }, for: .touchUpInside)
                stack.addArrangedSubview(btn)
                buttons.append(btn)
            }
            self.selectedIndex = selectedIndex
        }
        
        private func select(_ index: Int) {
            guard index != selectedIndex else { return }
            
            for (i, btn) in buttons.enumerated() {
                let isSelected = (i == index)
                let targetCorner = isSelected ? btn.bounds.height / 2 : 6
                let targetBG = isSelected ? UIColor.accent : UIColor.systemGray5
                let targetText = isSelected ? UIColor.white : UIColor.label
                
                // Annuler toute anim précédente sur ce bouton
                animators[i]?.stopAnimation(true)
                animators[i]?.finishAnimation(at: .current)
                
                // --- Animator pour corner + scale
                let animator = UIViewPropertyAnimator(duration: 0.8, dampingRatio: 0.8) {
                    btn.layer.cornerRadius = targetCorner
                    btn.transform = isSelected ? CGAffineTransform(scaleX: 1.05, y: 1.05) : .identity
                }
                animator.startAnimation()
                animators[i] = animator
                
                // --- Transition douce pour le background et le texte via configuration
                UIView.transition(with: btn, duration: 0.3, options: .transitionCrossDissolve) {
                    var newConfig = btn.configuration ?? UIButton.Configuration.filled()
                    newConfig.baseBackgroundColor = targetBG
                    newConfig.baseForegroundColor = targetText
                    btn.configuration = newConfig
                }
            }
            
            selectedIndex = index
            onSortSelected?(index)
        }
    }
}
