//
//  OverlayBottomViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 10/05/2025.
//

import UIKit

final class OverlayBottomViewController: UIViewController {

    // MARK: - Subviews

    private let infoView = OverlayBottomInfoView()
    private let reactionsController = OverlayReactionsViewController()
    private let containerView = UIStackView()

    private let infoAndInteractionStack = UIStackView()
    private let interactionView = UIView()

    private let gradientView = UIView()
    private let backgroundGradient = CAGradientLayer()
    private var gradientTopConstraint: NSLayoutConstraint?

    private var post: Post.Model?

    // MARK: - Callbacks

    var onTapLeft: (() -> Void)?
    var onTapRight: (() -> Void)?

    // MARK: - Init

    init(post: Post.Model) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupReactionsController()
        setupActions()
        setupGradient()

        if let post = post {
            infoView.configure(with: post)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = gradientView.bounds
    }

    // MARK: - Layout

    private func setupLayout() {
        // MARK: - containerView (horizontal stack)
        containerView.axis = .horizontal
        containerView.alignment = .fill
        containerView.distribution = .fill
        containerView.spacing = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            reactionsController.view.widthAnchor.constraint(equalToConstant: 56),
        ])

        // MARK: - infoAndInteractionStack (vertical stack)
        infoAndInteractionStack.axis = .vertical
        infoAndInteractionStack.spacing = 0
        infoAndInteractionStack.translatesAutoresizingMaskIntoConstraints = false

        // interactionView (expandable)
        interactionView.translatesAutoresizingMaskIntoConstraints = false
        interactionView.isUserInteractionEnabled = true
        interactionView.backgroundColor = .green.withAlphaComponent(0.2) // Debug

        // Priorités : interactionView remplit l'espace disponible
        interactionView.setContentHuggingPriority(.defaultLow, for: .vertical)
        interactionView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        // infoView (fixe en bas)
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoView.backgroundColor = .blue.withAlphaComponent(0.2) // Debug

        infoView.setContentHuggingPriority(.required, for: .vertical)
        infoView.setContentCompressionResistancePriority(.required, for: .vertical)

        setupTapZones() // ajoute les zones gauche/droite dans interactionView

        // Stack vertical : interactionView en haut, infoView en bas
        infoAndInteractionStack.addArrangedSubview(interactionView)
        infoAndInteractionStack.addArrangedSubview(infoView)

        // Stack horizontal : à gauche, info+interaction ; à droite, reactions
        containerView.addArrangedSubview(infoAndInteractionStack)
        containerView.addArrangedSubview(reactionsController.view)

        NSLayoutConstraint.activate([
            reactionsController.view.widthAnchor.constraint(equalToConstant: 56)
        ])
        
        containerView.backgroundColor = .orange.withAlphaComponent(0.5)
        interactionView.backgroundColor = .green.withAlphaComponent(0.5)
        infoAndInteractionStack.backgroundColor = .blue.withAlphaComponent(0.5)
    }
    

    private func setupTapZones() {
        let leftTap = UITapGestureRecognizer(target: self, action: #selector(handleLeftTap))
        let rightTap = UITapGestureRecognizer(target: self, action: #selector(handleRightTap))

        let leftZone = UIView()
        let rightZone = UIView()
        leftZone.translatesAutoresizingMaskIntoConstraints = false
        rightZone.translatesAutoresizingMaskIntoConstraints = false

        leftZone.isUserInteractionEnabled = true
        rightZone.isUserInteractionEnabled = true
        leftZone.addGestureRecognizer(leftTap)
        rightZone.addGestureRecognizer(rightTap)

        interactionView.addSubview(leftZone)
        interactionView.addSubview(rightZone)

        NSLayoutConstraint.activate([
            leftZone.leadingAnchor.constraint(equalTo: interactionView.leadingAnchor),
            leftZone.topAnchor.constraint(equalTo: interactionView.topAnchor),
            leftZone.bottomAnchor.constraint(equalTo: interactionView.bottomAnchor),
            leftZone.widthAnchor.constraint(equalTo: interactionView.widthAnchor, multiplier: 0.5),

            rightZone.trailingAnchor.constraint(equalTo: interactionView.trailingAnchor),
            rightZone.topAnchor.constraint(equalTo: interactionView.topAnchor),
            rightZone.bottomAnchor.constraint(equalTo: interactionView.bottomAnchor),
            rightZone.widthAnchor.constraint(equalTo: interactionView.widthAnchor, multiplier: 0.5)
        ])

        // Debug couleurs
//        leftZone.backgroundColor = .red.withAlphaComponent(0.5)
//        rightZone.backgroundColor = .blue.withAlphaComponent(0.5)
    }

    private func setupGradient() {
        backgroundGradient.colors = [
            UIColor.black.withAlphaComponent(0.4).cgColor,
            UIColor.black.withAlphaComponent(0.2).cgColor,
            UIColor.clear.cgColor
        ]
        backgroundGradient.locations = [0.0, 0.8, 1.0]
        backgroundGradient.startPoint = CGPoint(x: 0, y: 1.0)
        backgroundGradient.endPoint = CGPoint(x: 0, y: 0.0)

        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.layer.addSublayer(backgroundGradient)
        view.insertSubview(gradientView, at: 0)

        gradientTopConstraint = gradientView.topAnchor.constraint(
            equalTo: infoView.gradientAnchorView.topAnchor
        )

        NSLayoutConstraint.activate([
            gradientTopConstraint!,
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupReactionsController() {
        addChild(reactionsController)
        reactionsController.didMove(toParent: self)
    }

    // MARK: - Public API

    func configure(with post: Post.Model, safeAreaInsets: UIEdgeInsets) {
        self.post = post
        infoView.configure(with: post)
        infoView.applySafeAreaInsets(safeAreaInsets)
    }

    func applySafeAreaInsets(_ insets: UIEdgeInsets) {
        infoView.applySafeAreaInsets(insets)
        reactionsController.applySafeAreaInsets(insets)
    }

    // MARK: - Actions

    private func setupActions() {
        infoView.addSongButton.addTarget(self, action: #selector(didTapAddSong), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCommentView))
        infoView.commentView.addGestureRecognizer(tapGesture)
    }

    @objc private func didTapAddSong() {
        print("🎵 Add Song button tapped")
    }

    @objc private func didTapCommentView() {
        print("💬 Comment view tapped")
    }

    @objc private func handleLeftTap() {
        print("👈 Left tap detected in OverlayBottomViewController")
        onTapLeft?()
    }

    @objc private func handleRightTap() {
        print("👉 Right tap detected in OverlayBottomViewController")
        onTapRight?()
    }
}
