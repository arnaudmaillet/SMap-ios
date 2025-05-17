//
//  OverlayBottomViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 10/05/2025.
//

import UIKit

final class OverlayBottomViewController: UIViewController {

    // MARK: - Subviews

    private let overlayView = OverlayBottomView()
    private let reactionsController = OverlayReactionsViewController()
    private let horizontalStack = UIStackView()
    
    private let gradientView = UIView()
    private let backgroundGradient = CAGradientLayer()
    private var gradientTopConstraint: NSLayoutConstraint?

    private var post: Post.Model?

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
            overlayView.configure(with: post)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = gradientView.bounds
    }

    // MARK: - Layout

    private func setupLayout() {
        horizontalStack.axis = .horizontal
        horizontalStack.alignment = .bottom
        horizontalStack.distribution = .fill
        horizontalStack.spacing = 8
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        horizontalStack.addArrangedSubview(overlayView)
        horizontalStack.addArrangedSubview(reactionsController.view)
        view.addSubview(horizontalStack)

        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: view.topAnchor),
            horizontalStack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            horizontalStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            horizontalStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            reactionsController.view.widthAnchor.constraint(equalToConstant: 56)
        ])
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
            equalTo: overlayView.gradientAnchorView.topAnchor
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
        overlayView.configure(with: post)
        overlayView.applySafeAreaInsets(safeAreaInsets)
    }

    func applySafeAreaInsets(_ insets: UIEdgeInsets) {
        overlayView.applySafeAreaInsets(insets)
        reactionsController.applySafeAreaInsets(insets)
    }

    // MARK: - Actions

    private func setupActions() {
        overlayView.addSongButton.addTarget(self, action: #selector(didTapAddSong), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCommentView))
        overlayView.commentView.addGestureRecognizer(tapGesture)
    }

    @objc private func didTapAddSong() {
        print("🎵 Add Song button tapped")
        // TODO: ouvrir modal d’ajout de musique
    }

    @objc private func didTapCommentView() {
        print("💬 Comment view tapped")
        // TODO: ouvrir section commentaire
    }
}
