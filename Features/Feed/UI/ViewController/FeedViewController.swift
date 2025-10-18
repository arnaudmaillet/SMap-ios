//
//  FeedViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 05/10/2025.
//

import UIKit

extension FeedFeature.UI.ViewController {
    final class FeedViewController:
        UIViewController,
        UICollectionViewDataSource,
        UICollectionViewDelegate,
        UIScrollViewDelegate
    {
        typealias Post = PostFeature.Domain.Model.Post
        typealias MediaContent = MediaFeature.Domain.Model.MediaContent
        typealias Reaction = FeedFeature.UI.View.ReactionView.Reaction
        typealias OverlayView = FeedFeature.UI.View.OverlayView

        private let viewModel: FeedFeature.UI.ViewModel.FeedViewModel
        private var collectionView: UICollectionView!
        private var overlayView: FeedFeature.UI.View.OverlayView!
    
        
        private let reactions: [Reaction] = [
            .init(iconName: "heart.fill", count: "123K"),
            .init(iconName: "face.smiling.inverse", count: "12.3K"),
            .init(iconName: "hand.thumbsup.fill", count: "8.9K"),
            .init(iconName: "flame.fill", count: "6.4K"),
            .init(iconName: "star.fill", count: "63.7K"),
            .init(iconName: "moon.stars.fill", count: "4.5K"),
            .init(iconName: "paperplane.fill", count: "7.6K"),
            .init(iconName: "playstation.logo", count: "9.7K"),
            .init(iconName: "apple.image.playground", count: "67.1K"),
            .init(iconName: "apple.image.playground", count: "67.1K"),
            .init(iconName: "apple.image.playground", count: "67.1K"),
            .init(iconName: "apple.image.playground", count: "67.1K"),
            .init(iconName: "apple.image.playground", count: "67.1K"),
            .init(iconName: "apple.image.playground", count: "67.1K"),
            .init(iconName: "apple.image.playground", count: "67.1K")
        ]

        // MARK: - Init
        init(viewModel: FeedFeature.UI.ViewModel.FeedViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
            
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupCollectionView()
            setupOverlay()
        }
        
        private func setupCollectionView() {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 0
            layout.itemSize = UIScreen.main.bounds.size

            collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.isPagingEnabled = true
            collectionView.showsVerticalScrollIndicator = false
            collectionView.contentInsetAdjustmentBehavior = .never
            collectionView.backgroundColor = .black
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(FeedCell.self, forCellWithReuseIdentifier: "FeedCell")


            view.addSubview(collectionView)

            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: view.topAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }

        @objc func handleUserInfo() {
            print("User info tapped")
            // navigate to profile
        }

        @objc func handleFollow() {
            print("Follow tapped")
            // follow logic
        }
        
        private func setupOverlay() {
            overlayView = OverlayView()
            overlayView.translatesAutoresizingMaskIntoConstraints = false
            overlayView.addGestureRecognizer(collectionView.panGestureRecognizer)
            view.addSubview(overlayView)

            NSLayoutConstraint.activate([
                overlayView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
                overlayView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4),
                overlayView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                overlayView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ])
            
            overlayView.configure(with: reactions)
        }
        
        
        @objc func handleMusicPlayer() {
            print("Music player tapped")
        }

        @objc func handleAddMusicToPlaylist() {
            print("Add music tapped")
        }

        @objc func handleShare() {
            print("Share tapped")
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            viewModel.totalCount
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard
                let post = viewModel.post(at: indexPath.item),
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCell", for: indexPath) as? FeedCell
            else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: post, in: self)
            return cell
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offsetY = scrollView.contentOffset.y
            let screenHeight = scrollView.bounds.height
            guard screenHeight > 0 else { return }

            let rawIndex = offsetY / screenHeight
            let currentIndex = Int(round(rawIndex))
            let distanceToCenter = abs(rawIndex - CGFloat(currentIndex))
            let percentVisible = max(0, 1 - distanceToCenter)

            let threshold: CGFloat = 0.9
            let shouldShow = percentVisible >= threshold

            overlayView.setVisibility(shouldShow)
        }
    }
}

extension FeedFeature.UI.ViewController.FeedViewController: NavigationStackFeature.UI.Overlay.NavigationStackOverlayConfigurable {
    typealias NavigationStackOverlay = NavigationStackFeature.UI.Overlay.NavigationStackOverlay
    typealias NavbarConfig = NavigationStackFeature.UI.Overlay.NavbarConfig
    typealias ToolbarConfig = NavigationStackFeature.UI.Overlay.ToolbarConfig
    
    enum ToolbarItemType {
        case icon(String, Selector)
        case flexibleSpace
        case custom(UIBarButtonItem)
    }

    var navigationOverlay: NavigationStackOverlay {
        let navbar = NavbarConfig(
            title: nil,
            prefersLargeTitles: false,
            hidesNavbar: false,
            leftItems: nil,
            rightItems: makeRightNavbarItems()
        )

        let toolbar = ToolbarConfig(
            hidesToolbar: false,
            items: makeToolbarItems()
        )

        return NavigationStackOverlay(
            navbar: navbar,
            toolbar: toolbar,
            interfaceStyle: .dark
        )
    }

    private func makeRightNavbarItems() -> [UIBarButtonItem] {
        let followButton = UIButton(type: .system)
        followButton.setImage(UIImage(systemName: "plus"), for: .normal)
        followButton.tintColor = .accent
        followButton.addTarget(self, action: #selector(handleFollow), for: .touchUpInside)
        let followItem = UIBarButtonItem(customView: followButton)

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
        userInfoButton.addTarget(self, action: #selector(handleUserInfo), for: .touchUpInside)
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

        return [followItem, userInfoItem]
    }

    private func makeToolbarItems() -> [UIBarButtonItem] {
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

        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = .accent
        addButton.addTarget(self, action: #selector(handleAddMusicToPlaylist), for: .touchUpInside)
        let addItem = UIBarButtonItem(customView: addButton)

        let itemTypes: [ToolbarItemType] = [
            .custom(musicItem),
            .custom(addItem),
            .flexibleSpace,
            .icon("bookmark", #selector(handleShare)),
            .icon("arrow.2.squarepath", #selector(handleShare)),
            .flexibleSpace,
            .icon("qrcode", #selector(handleShare))
        ]

        return itemTypes.map { type in
            switch type {
            case .icon(let systemName, let action):
                let button = UIButton(type: .system)
                button.setImage(UIImage(systemName: systemName), for: .normal)
                button.tintColor = .label
                button.addTarget(self, action: action, for: .touchUpInside)
                return UIBarButtonItem(customView: button)

            case .flexibleSpace:
                return .flexibleSpace()

            case .custom(let item):
                return item
            }
        }
    }
}
