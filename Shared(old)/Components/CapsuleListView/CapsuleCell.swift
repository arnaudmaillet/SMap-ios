//
//  CapsuleCell.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 10/10/2025.
//

import UIKit

final class CapsuleCell: UICollectionViewCell {
    
    static let reuseIdentifier = "CapsuleCell"
    
    var onTap: (() -> Void)?
    
    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .secondarySystemBackground.withAlphaComponent(0.4)
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        
        // Police personnalisée
        let font = UIFont.systemFont(ofSize: 12, weight: .medium)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let attrTitle = NSAttributedString(string: "Placeholder", attributes: attributes)
        config.attributedTitle = AttributedString(attrTitle)
        
        button.configuration = config
        
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    func configure(text: String, onTap: (() -> Void)? = nil) {
        if #available(iOS 15.0, *) {
            let font = UIFont.systemFont(ofSize: 12, weight: .medium)
            let attributes: [NSAttributedString.Key: Any] = [.font: font]
            let attr = NSAttributedString(string: text, attributes: attributes)
            button.configuration?.attributedTitle = AttributedString(attr)
        } else {
            button.setTitle(text, for: .normal)
        }
        
        self.onTap = onTap
    }
    
    @objc private func handleTap() {
        onTap?()
    }
}
