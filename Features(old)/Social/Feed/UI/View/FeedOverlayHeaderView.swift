//
//  FeedNavigationConfigurator.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 08/10/2025.
//

import UIKit

extension FeedFeature.UI.View {

    final class FeedNavigationConfigurator {

        // MARK: - Nested Type

        enum ToolbarItemType {
            case icon(String)
            case flexibleSpace
            case custom(UIBarButtonItem)
        }

        // MARK: - Properties

        weak var viewController: UIViewController?

        private var itemTypes: [ToolbarItemType] = []

        // MARK: - Init

        init(viewController: UIViewController) {
            self.viewController = viewController
        }

        // MARK: - Public Methods

        func setupNavigationBar() {
            guard let vc = viewController else { return }

//            vc.navigationItem.backBarButtonItem = UIBarButtonItem(
//                image: UIImage(systemName: "chevron.left"),
//                style: .plain,
//                target: vc,
//                action: #selector(FeedFeature.UI.ViewController.FeedViewController.handleBack)
//            )

            // Follow
            let followButton = UIButton(type: .system)
            followButton.setImage(
                UIImage(systemName: "plus"),
                for: .normal
            )
            followButton.tintColor = .accent
            followButton.addTarget(
                vc,
                action: #selector(FeedFeature.UI.ViewController.FeedViewController.handleFollow),
                for: .touchUpInside
            )
            let followItem = UIBarButtonItem(customView: followButton)

            // User Info
            let avatar = UIImageView()
            avatar.image = UIImage(systemName: "person.crop.circle.fill")
            avatar.tintColor = .gray
            avatar.contentMode = .scaleAspectFit

            let label = UILabel()
            label.text = "john_doe"
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = .label

            let stack = UIStackView(arrangedSubviews: [avatar, label])
            stack.axis = .horizontal
            stack.spacing = 6
            stack.alignment = .center

            let userInfoButton = UIButton(type: .system)
            userInfoButton.tintColor = .label
            userInfoButton.addTarget(
                vc,
                action: #selector(FeedFeature.UI.ViewController.FeedViewController.handleUserInfo),
                for: .touchUpInside
            )
            userInfoButton.addSubview(stack)

            stack.translatesAutoresizingMaskIntoConstraints = false
            avatar.translatesAutoresizingMaskIntoConstraints = false

            avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor).isActive = true
            avatar.heightAnchor.constraint(equalTo: stack.heightAnchor).isActive = true

            NSLayoutConstraint.activate([
                stack.leadingAnchor.constraint(equalTo: userInfoButton.leadingAnchor),
                stack.trailingAnchor.constraint(equalTo: userInfoButton.trailingAnchor),
                stack.topAnchor.constraint(equalTo: userInfoButton.topAnchor),
                stack.bottomAnchor.constraint(equalTo: userInfoButton.bottomAnchor)
            ])

            let userInfoItem = UIBarButtonItem(customView: userInfoButton)

            vc.navigationItem.rightBarButtonItems = [followItem, userInfoItem]
        }

        func setupToolbar() {
            guard let vc = viewController as? FeedFeature.UI.ViewController.FeedViewController else { return }

            // 💿 Music Info

            let disc = UIImageView()
            disc.image = UIImage(systemName: "opticaldisc.fill")
            disc.tintColor = .label
            disc.contentMode = .scaleAspectFit
            disc.translatesAutoresizingMaskIntoConstraints = false
            disc.widthAnchor.constraint(equalToConstant: 32).isActive = true
            disc.heightAnchor.constraint(equalToConstant: 32).isActive = true

            let title = UILabel()
            title.text = "Never Gonna Give You Up"
            title.font = .systemFont(ofSize: 13, weight: .semibold)
            title.textColor = .label
            title.lineBreakMode = .byTruncatingTail

            let artist = UILabel()
            artist.text = "Rick Astley"
            artist.font = .systemFont(ofSize: 11, weight: .regular)
            artist.textColor = .secondaryLabel
            artist.lineBreakMode = .byTruncatingTail

            let infoStack = UIStackView(arrangedSubviews: [title, artist])
            infoStack.axis = .vertical
            infoStack.spacing = 2
            infoStack.alignment = .leading

            let musicStack = UIStackView(arrangedSubviews: [disc, infoStack])
            musicStack.axis = .horizontal
            musicStack.spacing = 4
            musicStack.alignment = .center
            musicStack.translatesAutoresizingMaskIntoConstraints = false

            let musicContainer = UIView()
            musicContainer.addSubview(musicStack)
            NSLayoutConstraint.activate([
                musicStack.topAnchor.constraint(equalTo: musicContainer.topAnchor),
                musicStack.bottomAnchor.constraint(equalTo: musicContainer.bottomAnchor),
                musicStack.leadingAnchor.constraint(equalTo: musicContainer.leadingAnchor),
                musicStack.trailingAnchor.constraint(equalTo: musicContainer.trailingAnchor),
                musicContainer.heightAnchor.constraint(equalToConstant: 32)
            ])

            let musicItem = UIBarButtonItem(customView: musicContainer)

            // ➕ Add Button
            let addButton = UIButton(type: .system)
            addButton.setImage(UIImage(systemName: "plus"), for: .normal)
            addButton.tintColor = .accent
            addButton.addTarget(vc, action: #selector(vc.handleAddMusicToPlaylist), for: .touchUpInside)
            addButton.translatesAutoresizingMaskIntoConstraints = false
            let addItem = UIBarButtonItem(customView: addButton)

            // 🔁 Met à jour la liste avec .custom() inclus
            self.itemTypes = [
                .custom(musicItem),
                .custom(addItem),
                .flexibleSpace,
                .icon("bookmark"),
                .icon("arrow.2.squarepath"),
                .flexibleSpace,
                .icon("qrcode")
            ]

            let items: [UIBarButtonItem] = itemTypes.map { type in
                switch type {
                case .icon(let iconName):
                    let button = UIButton(type: .system)
                    button.setImage(UIImage(systemName: iconName), for: .normal)
                    button.tintColor = .label
                    button.addTarget(vc, action: #selector(vc.handleShare), for: .touchUpInside)
                    button.translatesAutoresizingMaskIntoConstraints = false
                    return UIBarButtonItem(customView: button)

                case .flexibleSpace:
                    return .flexibleSpace()

                case .custom(let item):
                    return item
                }
            }

            vc.toolbarItems = items
            vc.navigationController?.isToolbarHidden = false
        }
    }
}
