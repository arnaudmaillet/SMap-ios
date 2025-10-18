//
//  HomeSmallActionButtonCell.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 22/06/2025.
//

import UIKit

final class HomeSmallActionButtonCell: UICollectionViewCell {
    static let reuseIdentifier = "HomeSmallActionButtonCell"
    
    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemMaterial)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let hStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 4
        s.alignment = .center
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    private var animator: UIViewPropertyAnimator?
    private var isActive: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        contentView.addSubview(blurView)
        blurView.contentView.addSubview(hStack)
        
        blurView.layer.cornerRadius = 10
        blurView.layer.masksToBounds = true
        blurView.layer.borderWidth = 1
        blurView.layer.borderColor = UIColor.separator.cgColor
        
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .label
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        hStack.addArrangedSubview(iconView)
        hStack.addArrangedSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: contentView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hStack.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 4),
            hStack.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -4),
            hStack.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 8),
            hStack.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -8),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
        ])
    }
    
    func configure(with model: HomeActionButtonModel, active: Bool) {
        iconView.image = model.iconName != nil ? UIImage(systemName: model.iconName!) : nil
        iconView.isHidden = (model.iconName == nil)
        titleLabel.text = model.title ?? ""
        titleLabel.isHidden = (model.title == nil)
        setActive(active, animated: false)
    }
    
    func setActive(_ active: Bool, animated: Bool = true) {
        isActive = active
        
        animator?.stopAnimation(true)
        
        let backgroundColor: UIColor = active ? .accent : .clear
        let textColor: UIColor = active ? .accent : .label
        let targetRadius: CGFloat = active ? bounds.height / 2 : 10
        let borderColor: UIColor = active ? .accent : .separator
        
        let changes = {
            self.blurView.backgroundColor = backgroundColor.withAlphaComponent(active ? 0.4 : 0.0)
            self.titleLabel.textColor = textColor
            self.iconView.tintColor = textColor
            self.blurView.layer.cornerRadius = targetRadius
            self.blurView.layer.borderColor = borderColor.cgColor
        }
        
        if animated {
            animator = UIViewPropertyAnimator(duration: 0.22, curve: .easeInOut, animations: changes)
            animator?.startAnimation()
        } else {
            changes()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Capsule sur resize
        blurView.layer.cornerRadius = isActive ? bounds.height / 2 : 10
    }
}
