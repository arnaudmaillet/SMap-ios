//
//  OverlayReactionsView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 30/04/2025.
//

import UIKit

final class OverlayReactionsView: UIView {

    private let likeButton = makeButton(iconName: "heart.fill", count: "123K")
    private let watchButton = makeButton(iconName: "eye.fill", count: "2.3k")
    private let shareButton = makeButton(iconName: "arrowshape.turn.up.forward.fill")

    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setup() {
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(likeButton)
        stackView.addArrangedSubview(watchButton)
        stackView.addArrangedSubview(shareButton)

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private static func makeButton(iconName: String, count: String) -> UIView {
        let imageView = UIImageView(image: UIImage(systemName: iconName))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 32).isActive = true

        let label = UILabel()
        label.text = count
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }
    
    private static func makeButton(iconName: String) -> UIView {
        let imageView = UIImageView(image: UIImage(systemName: iconName))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 32).isActive = true

        return imageView
    }
}
