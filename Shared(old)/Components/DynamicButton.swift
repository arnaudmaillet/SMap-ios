//
//  DynamicButton.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/04/2025.
//

import UIKit

final class DynamicButton: UIControl {
    
    private let backgroundView = UIView()
    private let contentLabel = UILabel()

    private lazy var instantTapRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handlePress(_:)))
        recognizer.minimumPressDuration = 0
        recognizer.cancelsTouchesInView = false
        return recognizer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundView.backgroundColor = .accent
        backgroundView.layer.cornerRadius = 16
        backgroundView.isUserInteractionEnabled = false
        addSubview(backgroundView)

        contentLabel.text = "Follow"
        contentLabel.textAlignment = .center
        contentLabel.font = .boldSystemFont(ofSize: 14)
        contentLabel.textColor = .white
        addSubview(contentLabel)

        addGestureRecognizer(instantTapRecognizer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
        contentLabel.frame = bounds
        backgroundView.layer.cornerRadius = bounds.height / 2
    }

    @objc private func handlePress(_ recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            animatePressDown()
        case .ended, .cancelled, .failed:
            animatePressUp()
        default:
            break
        }
    }

    private func animatePressDown() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut], animations: {
            self.backgroundView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.contentLabel.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: nil)
    }

    private func animatePressUp() {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: [], animations: {
            self.backgroundView.transform = .identity
            self.contentLabel.transform = .identity
        }, completion: nil)
    }
}
