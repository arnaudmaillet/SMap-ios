//
//  OverlayReactionsView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 30/04/2025.
//

import UIKit

final class OverlayReactionsView: UIView {

    private let starButton = makeButton(iconName: "star.fill", count: "2.3k")
    private let shareButton = makeButton(iconName: "arrowshape.turn.up.forward.fill")

    private let mainStackView = UIStackView()
    private let reactionsContainer = UIView()
    private let reactionsScrollView = IsolatedScrollView()
    private let reactionsStackView = UIStackView()
    private let addButton = UIButton(type: .system)

    private let initialReactions = [
        ("heart.fill", "123K"),
        ("face.smiling.inverse", "12.3K"),
        ("hand.thumbsup.fill", "8.9K"),
        ("flame.fill", "6.7K")
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setup() {
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        // Style du container de réactions
        reactionsContainer.translatesAutoresizingMaskIntoConstraints = false
        reactionsContainer.backgroundColor = .blue.withAlphaComponent(0.8)
        reactionsContainer.layer.cornerRadius = 16
        reactionsContainer.clipsToBounds = true

        // ScrollView
        reactionsScrollView.translatesAutoresizingMaskIntoConstraints = false
        reactionsScrollView.showsVerticalScrollIndicator = false

        reactionsStackView.axis = .vertical
        reactionsStackView.alignment = .center
        reactionsStackView.spacing = 16
        reactionsStackView.translatesAutoresizingMaskIntoConstraints = false

        reactionsScrollView.addSubview(reactionsStackView)

        NSLayoutConstraint.activate([
            reactionsStackView.topAnchor.constraint(equalTo: reactionsScrollView.topAnchor),
            reactionsStackView.leadingAnchor.constraint(equalTo: reactionsScrollView.leadingAnchor),
            reactionsStackView.trailingAnchor.constraint(equalTo: reactionsScrollView.trailingAnchor),
            reactionsStackView.bottomAnchor.constraint(equalTo: reactionsScrollView.bottomAnchor),
            reactionsStackView.widthAnchor.constraint(equalTo: reactionsScrollView.widthAnchor)
        ])

        // Réactions initiales
        for reaction in initialReactions {
            reactionsStackView.addArrangedSubview(Self.makeButton(iconName: reaction.0, count: reaction.1))
        }

        // Bouton +
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = .white
        addButton.addTarget(self, action: #selector(addReactionTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        // Container layout
        reactionsContainer.addSubview(reactionsScrollView)
        reactionsContainer.addSubview(addButton)

        NSLayoutConstraint.activate([
            reactionsScrollView.topAnchor.constraint(equalTo: reactionsContainer.topAnchor),
            reactionsScrollView.leadingAnchor.constraint(equalTo: reactionsContainer.leadingAnchor),
            reactionsScrollView.trailingAnchor.constraint(equalTo: reactionsContainer.trailingAnchor),
            reactionsScrollView.heightAnchor.constraint(equalToConstant: 200),

            addButton.topAnchor.constraint(equalTo: reactionsScrollView.bottomAnchor, constant: 2),
            addButton.centerXAnchor.constraint(equalTo: reactionsContainer.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: reactionsContainer.bottomAnchor)
        ])

        // Ajout au stack principal
        mainStackView.addArrangedSubview(reactionsContainer)
        mainStackView.addArrangedSubview(starButton)
        mainStackView.addArrangedSubview(shareButton)

        addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func addReactionTapped() {
        print("Ajout d'un nouveau emote")
        let newReaction = Self.makeButton(iconName: "bolt.fill", count: "1")
        reactionsStackView.addArrangedSubview(newReaction)
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        if let scrollView = self.reactionsScrollView as? IsolatedScrollView,
           let parent = self.findParentViewController(ofType: FeedViewController.self) {
            parent.isInteractingWithReactionScroll = true
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        if let scrollView = self.reactionsScrollView as? IsolatedScrollView,
           let parent = self.findParentViewController(ofType: FeedViewController.self) {
            parent.isInteractingWithReactionScroll = false
        }
    }
}


extension UIView {
    func findParentViewController<T: UIViewController>(ofType type: T.Type) -> T? {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? T {
                return vc
            }
            responder = responder?.next
        }
        return nil
    }
}
