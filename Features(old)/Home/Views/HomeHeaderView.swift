//
//  HomeHeaderView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 22/06/2025.
//

import UIKit

final class HomeHeaderView: UIView {
    private let titleLabel = UILabel()
    private let userButton = UIButton(type: .system)
    private let hStack = UIStackView()
    var onUserButtonTapped: (() -> Void)?
    
    private let blurContainer: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemMaterial)
        let v = UIVisualEffectView(effect: blur)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 20 // pour un carré de 40x40
        v.clipsToBounds = true
        // --- Bordure blanche ---
        v.layer.borderColor = UIColor.separator.cgColor
        v.layer.borderWidth = 1
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupView() {
        backgroundColor = .clear
        
        titleLabel.text = ""
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.textColor = .label.withAlphaComponent(0.8)
        
        let userIcon = UIImage(systemName: "person.crop.circle")
        userButton.setImage(userIcon, for: .normal)
        userButton.tintColor = .label.withAlphaComponent(0.8)
        userButton.contentHorizontalAlignment = .fill
        userButton.contentVerticalAlignment = .fill
        userButton.translatesAutoresizingMaskIntoConstraints = false
        userButton.addTarget(self, action: #selector(handleUserTap), for: .touchUpInside)
        
        blurContainer.contentView.addSubview(userButton)
        
        NSLayoutConstraint.activate([
            userButton.centerXAnchor.constraint(equalTo: blurContainer.contentView.centerXAnchor),
            userButton.centerYAnchor.constraint(equalTo: blurContainer.contentView.centerYAnchor),
            userButton.widthAnchor.constraint(equalToConstant: 28),
            userButton.heightAnchor.constraint(equalToConstant: 28),
            blurContainer.widthAnchor.constraint(equalToConstant: 40),
            blurContainer.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        blurContainer.layer.shadowColor = UIColor.black.cgColor
        blurContainer.layer.shadowRadius = 8
        blurContainer.layer.shadowOpacity = 0.15
        blurContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.distribution = .equalSpacing
        hStack.spacing = 12
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        hStack.addArrangedSubview(titleLabel)
        hStack.addArrangedSubview(blurContainer)
        
        addSubview(hStack)
        
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            hStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
            hStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func handleUserTap() {
        onUserButtonTapped?()
    }
    
    func setTitle(_ text: String) { titleLabel.text = text }
}
