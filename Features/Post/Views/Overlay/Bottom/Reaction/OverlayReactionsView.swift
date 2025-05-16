//
//  OverlayReactionsView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 30/04/2025.
//

import UIKit

final class ScrollTrapView: UIScrollView, UIGestureRecognizerDelegate {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        isScrollEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        alwaysBounceHorizontal = true
        alwaysBounceVertical = false
        bounces = false
        isPagingEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        contentInsetAdjustmentBehavior = .never

        panGestureRecognizer.delegate = self
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

final class OverlayReactionsView: UIView {

    private let starButton = makeButton(iconName: "star.fill", count: "2.3k")
    private let shareButton = makeButton(iconName: "arrowshape.turn.up.forward.fill")

    private let mainStackView = UIStackView()
    private let reactionsContainer = UIView()
    private let scrollTrapView = ScrollTrapView()
    private let reactionsScrollView = UIScrollView()
    private let reactionsStackView = UIStackView()

    // MARK: - Public API
    var scrollView: UIScrollView {
        return reactionsScrollView
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setup() {
        // Layout principal
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        reactionsContainer.translatesAutoresizingMaskIntoConstraints = false
        reactionsContainer.layer.cornerRadius = 16
        reactionsContainer.clipsToBounds = true
        reactionsContainer.heightAnchor.constraint(equalToConstant: 200).isActive = true

        scrollTrapView.translatesAutoresizingMaskIntoConstraints = false

        reactionsScrollView.translatesAutoresizingMaskIntoConstraints = false
        reactionsScrollView.showsVerticalScrollIndicator = false
        reactionsScrollView.isScrollEnabled = true

        reactionsStackView.axis = .vertical
        reactionsStackView.alignment = .fill
        reactionsStackView.spacing = 16
        reactionsStackView.translatesAutoresizingMaskIntoConstraints = false

        reactionsScrollView.addSubview(reactionsStackView)
        scrollTrapView.addSubview(reactionsScrollView)
        reactionsContainer.addSubview(scrollTrapView)


        // Pour éviter que la stack ait une hauteur nulle
        let minHeight = reactionsStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 1)
        minHeight.priority = .defaultLow
        minHeight.isActive = true

        NSLayoutConstraint.activate([
            // stack inside scrollView
            reactionsStackView.topAnchor.constraint(equalTo: reactionsScrollView.topAnchor),
            reactionsStackView.leadingAnchor.constraint(equalTo: reactionsScrollView.leadingAnchor),
            reactionsStackView.trailingAnchor.constraint(equalTo: reactionsScrollView.trailingAnchor),
            reactionsStackView.bottomAnchor.constraint(equalTo: reactionsScrollView.bottomAnchor),
            reactionsStackView.widthAnchor.constraint(equalTo: reactionsScrollView.widthAnchor),

            // scrollView inside trap
            reactionsScrollView.topAnchor.constraint(equalTo: scrollTrapView.topAnchor),
            reactionsScrollView.leadingAnchor.constraint(equalTo: scrollTrapView.leadingAnchor),
            reactionsScrollView.trailingAnchor.constraint(equalTo: scrollTrapView.trailingAnchor),
            reactionsScrollView.bottomAnchor.constraint(equalTo: scrollTrapView.bottomAnchor),
            reactionsScrollView.heightAnchor.constraint(equalTo: scrollTrapView.heightAnchor),
            reactionsScrollView.widthAnchor.constraint(equalTo: scrollTrapView.widthAnchor),

            // trap in container
            scrollTrapView.topAnchor.constraint(equalTo: reactionsContainer.topAnchor),
            scrollTrapView.leadingAnchor.constraint(equalTo: reactionsContainer.leadingAnchor),
            scrollTrapView.trailingAnchor.constraint(equalTo: reactionsContainer.trailingAnchor),
            scrollTrapView.bottomAnchor.constraint(equalTo: reactionsContainer.bottomAnchor)
        ])
        

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
    
    func configure(with reactions: [(String, String)]) {
        reactionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        print("configure")
        print(reactions)
        for reaction in reactions {
            reactionsStackView.addArrangedSubview(Self.makeButton(iconName: reaction.0, count: reaction.1))
        }
    }

    private static func makeButton(iconName: String, count: String) -> UIView {
        guard let image = UIImage(systemName: iconName) else {
            print("⚠️ SF Symbol non trouvé: \(iconName)")
            return UIView() // vide si le symbole n'existe pas
        }

        let imageView = UIImageView(image: image)
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
        stack.backgroundColor = .red.withAlphaComponent(0.5)
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
