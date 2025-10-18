//
//  HomeActionButtonCell.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/06/2025.
//

import UIKit

final class HomeActionButtonCell: UICollectionViewCell {
    static let reuseIdentifier = "HomeActionButtonCell"
    
    private var isActive: Bool = false

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
        s.spacing = 8
        s.alignment = .center
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    private var animator: UIViewPropertyAnimator?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        contentView.addSubview(blurView)
        blurView.contentView.addSubview(hStack)

        blurView.layer.cornerRadius = 16
        blurView.layer.masksToBounds = true
        blurView.layer.borderWidth = 1
        blurView.layer.borderColor = UIColor.separator.cgColor

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .label
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .preferredFont(forTextStyle: .subheadline)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        hStack.addArrangedSubview(iconView)
        hStack.addArrangedSubview(titleLabel)

        // 1. BlurView doit remplir tout le contentView
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: contentView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        // 2. StackView doit remplir le blurView.contentView avec padding
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 8),
            hStack.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -8),
            hStack.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 12),
            hStack.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -12),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
        ])
    }

    func setActive(_ active: Bool, animated: Bool = true) {
        isActive = active

        animator?.stopAnimation(true)

        let backgroundColor: UIColor = active ? .accent : .clear
        let textColor: UIColor = active ? .accent : .label
        let targetRadius: CGFloat = active ? bounds.height / 2 : 16
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
        // Pour garder un radius bien capsule sur resize
        if isActive {
            blurView.layer.cornerRadius = bounds.height / 2
        } else {
            blurView.layer.cornerRadius = 16
        }
    }

    func configure(with model: HomeActionButtonModel, active: Bool) {
        iconView.image = model.iconName != nil ? UIImage(systemName: model.iconName!) : nil
        iconView.isHidden = (model.iconName == nil)
        titleLabel.text = model.title ?? ""
        titleLabel.isHidden = (model.title == nil)
        setActive(active, animated: false)
    }
}
