//
//  FeedCell.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 08/10/2025.
//

import UIKit

extension FeedFeature.UI.ViewController {
    final class FeedCell: UICollectionViewCell {
        private weak var embeddedController: FeedPostViewController?

        override func prepareForReuse() {
            super.prepareForReuse()
            cleanupEmbeddedController()
        }

        private func cleanupEmbeddedController() {
            embeddedController?.cleanupController()
            embeddedController = nil
        }
        
        func configure(with post: PostNamespace.Domain.Entities.Post, in parent: UIViewController) {
            cleanupEmbeddedController()

            let controller = FeedPostViewController(post: post)
            embeddedController = controller

            parent.addChild(controller)
            contentView.addSubview(controller.view)

            controller.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                controller.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                controller.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                controller.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                controller.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])

            controller.didMove(toParent: parent)

            // 👉 Injection des insets
            let safeInsets = parent.view.safeAreaInsets
            controller.applySafeAreaInsets(safeInsets)
        }
    }
}

//extension FeedFeature.UI.ViewController {
//    final class FeedCell: UICollectionViewCell {
//        private weak var embeddedController: FeedPostViewController?
//
//        override func prepareForReuse() {
//            super.prepareForReuse()
//            cleanupEmbeddedController()
//        }
//
//        private func cleanupEmbeddedController() {
//            embeddedController?.cleanupController()
//            embeddedController = nil
//        }
//
//        func configure(with post: PostFeature.Domain.Model.Post, in parent: UIViewController) {
//            cleanupEmbeddedController()
//
//            let controller = FeedPostViewController(post: post)
//            embeddedController = controller
//            
//            let safeInsets = parent.view.safeAreaInsets
//            controller.applySafeAreaInsets(safeInsets)
//
//            parent.addChild(controller)
//            contentView.addSubview(controller.view)
//
//            controller.view.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                controller.view.topAnchor.constraint(equalTo: contentView.topAnchor),
//                controller.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//                controller.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//                controller.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
//            ])
//            
//            controller.didMove(toParent: parent)
//        }
//    }
//}

