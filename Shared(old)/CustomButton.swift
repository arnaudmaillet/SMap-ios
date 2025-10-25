//
//  CustomButton.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 05/08/2025.
//

import UIKit

final class CustomButton: UIButton {
    static let defaultCornerPercent: CGFloat = 0.64
    static let selectedCornerPercent: CGFloat = 0.88
    
    // MARK: - Public properties
    var cornerPercent: CGFloat = defaultCornerPercent {
        didSet { setNeedsLayout() }
    }
    
    var icon: UIImage? {
        didSet {
            setImage(icon, for: .normal)
            setTitle(nil, for: .normal)
            invalidateIntrinsicContentSize()
        }
    }
    
    var defaultBackgroundColor: UIColor = .systemGray5 { didSet { updateStyle() } }
    var selectedBackgroundColor: UIColor = .systemGray2 { didSet { updateStyle() } }
    var normalTitleColor: UIColor = .label { didSet { updateStyle() } }
    var selectedTitleColor: UIColor = .white { didSet { updateStyle() } }
    var directionalContentInsets: NSDirectionalEdgeInsets = .zero { didSet { invalidateIntrinsicContentSize() } }
    var titleText: String = "" { didSet { setTitle(titleText, for: .normal); invalidateIntrinsicContentSize() } }
    var invertTitleColors: Bool = false { didSet { updateStyle() } }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        layer.masksToBounds = true
        updateStyle()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Size
    override var intrinsicContentSize: CGSize {
        if let imageView = imageView, icon != nil {
            let imageSize = imageView.intrinsicContentSize
            let width = imageSize.width + directionalContentInsets.leading + directionalContentInsets.trailing
            let height = imageSize.height + directionalContentInsets.top + directionalContentInsets.bottom
            return CGSize(width: width, height: max(height, 32))
        }

        let labelSize = titleLabel?.intrinsicContentSize ?? .zero
        let width = labelSize.width + directionalContentInsets.leading + directionalContentInsets.trailing
        let height = max(labelSize.height + directionalContentInsets.top + directionalContentInsets.bottom, 32)
        return CGSize(width: width, height: height)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        let maxRadius = bounds.height / 2
        layer.cornerRadius = (maxRadius - 0) * cornerPercent
    }
    
    // MARK: - State
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
                self.updateStyle()
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            UIViewPropertyAnimator(duration: 0.8, dampingRatio: 0.6) {
                self.cornerPercent = self.isSelected ? Self.selectedCornerPercent : Self.defaultCornerPercent
                self.transform = self.isSelected ? CGAffineTransform(scaleX: 1.05, y: 1.05) : .identity
            }.startAnimation()

            UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve) {
                self.updateStyle()
            }
        }
    }
    
    // MARK: - Style
    private func updateStyle() {
        backgroundColor = isSelected ? selectedBackgroundColor : defaultBackgroundColor
        
        let normalText = invertTitleColors ? selectedTitleColor : normalTitleColor
        let selectedText = invertTitleColors ? normalTitleColor : selectedTitleColor
        
        let textColor = isSelected ? selectedText : normalText
        setTitleColor(textColor, for: .normal)
        tintColor = textColor
    }
}
