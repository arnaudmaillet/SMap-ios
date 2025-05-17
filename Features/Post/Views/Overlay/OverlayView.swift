//
//  OverlayView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 11/05/2025.
//

//import UIKit
//
//final class OverlayView: UIView {
//
//    // MARK: - Subviews
//
//    let topViewContainer = UIView()
//    let bottomContainerView = UIView()
//    private let mainStackView = UIStackView()
//
//    // MARK: - Init
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError()
//    }
//
//    // MARK: - Setup
//
//    private func setupView() {
//        backgroundColor = .clear
//
//        // Containers config
//        topViewContainer.translatesAutoresizingMaskIntoConstraints = false
//        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
//
//        topViewContainer.backgroundColor = .blue.withAlphaComponent(0.1)
//        bottomContainerView.backgroundColor = .red.withAlphaComponent(0.1)
//
//        // Hugging priorities
//        topViewContainer.setContentHuggingPriority(.required, for: .vertical)
//        topViewContainer.setContentCompressionResistancePriority(.required, for: .vertical)
//
//        bottomContainerView.setContentHuggingPriority(.defaultLow, for: .vertical)
//        bottomContainerView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
//
//        // StackView setup
//        mainStackView.axis = .vertical
//        mainStackView.distribution = .fill
//        mainStackView.alignment = .fill
//        mainStackView.translatesAutoresizingMaskIntoConstraints = false
//
//        mainStackView.addArrangedSubview(topViewContainer)
//        mainStackView.addArrangedSubview(bottomContainerView)
//
//        addSubview(mainStackView)
//
//        NSLayoutConstraint.activate([
//            mainStackView.topAnchor.constraint(equalTo: topAnchor),
//            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
//        ])
//    }
//
//    // MARK: - View Controller Injection
//
//    func injectTopViewController(_ vc: UIViewController, into parent: UIViewController) {
//        topViewContainer.subviews.forEach { $0.removeFromSuperview() }
//        parent.addChild(vc)
//
//        let childView = vc.view!
//        childView.translatesAutoresizingMaskIntoConstraints = false
//        topViewContainer.addSubview(childView)
//
//        NSLayoutConstraint.activate([
//            childView.topAnchor.constraint(equalTo: topViewContainer.topAnchor),
//            childView.bottomAnchor.constraint(equalTo: topViewContainer.bottomAnchor),
//            childView.leadingAnchor.constraint(equalTo: topViewContainer.leadingAnchor),
//            childView.trailingAnchor.constraint(equalTo: topViewContainer.trailingAnchor)
//        ])
//
//        vc.didMove(toParent: parent)
//    }
//
//    func injectBottomViewController(_ vc: UIViewController, into parent: UIViewController) {
//        bottomContainerView.subviews.forEach { $0.removeFromSuperview() }
//        parent.addChild(vc)
//
//        let childView = vc.view!
//        childView.translatesAutoresizingMaskIntoConstraints = false
//        bottomContainerView.addSubview(childView)
//
//        NSLayoutConstraint.activate([
//            childView.topAnchor.constraint(equalTo: bottomContainerView.topAnchor),
//            childView.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor),
//            childView.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
//            childView.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor)
//        ])
//
//        vc.didMove(toParent: parent)
//    }
//}


import UIKit

final class OverlayView: UIView {

    // MARK: - Subviews

    private let topViewContainer = UIView()
    let bottomContainerView = UIView()

    private var bottomConstraint: NSLayoutConstraint?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Layout

    private func setupViews() {
        backgroundColor = .clear

        [topViewContainer, bottomContainerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        topViewContainer.setContentHuggingPriority(.required, for: .vertical)
        topViewContainer.setContentCompressionResistancePriority(.required, for: .vertical)

        bottomContainerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        bottomContainerView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        NSLayoutConstraint.activate([
            topViewContainer.topAnchor.constraint(equalTo: topAnchor),
            topViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            topViewContainer.trailingAnchor.constraint(equalTo: trailingAnchor),

            bottomContainerView.topAnchor.constraint(equalTo: topViewContainer.bottomAnchor),
            bottomContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - View Controller Injection

    func injectTopViewController(_ vc: UIViewController, into parent: UIViewController) {
        topViewContainer.subviews.forEach { $0.removeFromSuperview() }
        parent.addChild(vc)

        let childView = vc.view!
        childView.translatesAutoresizingMaskIntoConstraints = false
        topViewContainer.addSubview(childView)

        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: topViewContainer.topAnchor),
            childView.bottomAnchor.constraint(equalTo: topViewContainer.bottomAnchor),
            childView.leadingAnchor.constraint(equalTo: topViewContainer.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: topViewContainer.trailingAnchor)
        ])

        vc.didMove(toParent: parent)
    }

    func injectBottomViewController(_ vc: UIViewController, into parent: UIViewController) {
        bottomContainerView.subviews.forEach { $0.removeFromSuperview() }
        parent.addChild(vc)

        let childView = vc.view!
        childView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.addSubview(childView)

        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            childView.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor),
            childView.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor)
        ])

        vc.didMove(toParent: parent)
    }
}
