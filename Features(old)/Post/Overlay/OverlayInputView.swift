//
//  OverlayInputView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/05/2025.
//

import UIKit

final class CommentInputView: UIView {

    let inputField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.placeholder = "Ajouter un commentaire..."
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Envoyer", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(inputField)
        stackView.addArrangedSubview(sendButton)

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            sendButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
}
