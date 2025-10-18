//
//  ProfileViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 12/10/2025.
//

import UIKit

extension ProfileFeature.UI.ViewController {
    
    final class ProfileViewController: UIViewController {
        
        typealias ProfileViewModel = ProfileFeature.UI.ViewModel.ProfileViewModel
        var collectionView: UICollectionView = UICollectionView()
        
        private let bannerMediaView = UIView()
        private let viewModel: ProfileViewModel
        
        // MARK: - Lifecycle
        
        init(viewModel: ProfileViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
        }

        // MARK: - Setup

        private func setupUI() {
            view.backgroundColor = .red
        }
        
        private func setupCollectionView() {
            let layout = makeLayout()
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.backgroundColor = .clear
            collectionView.contentInsetAdjustmentBehavior = .never
            collectionView.showsVerticalScrollIndicator = false
            view.insertSubview(collectionView, aboveSubview: bannerMediaView)
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: view.topAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            collectionView.register(
                ProfileInfoViewCell.self,
                forCellWithReuseIdentifier: ProfileInfoViewCell.reuseIdentifier
            )
            collectionView.register(
                Gallery.MenuTabViewCell.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: Gallery.MenuTabViewCell.reuseIdentifier
            )
            collectionView.register(
                Gallery.ContainerViewCell.self,
                forCellWithReuseIdentifier: Gallery.ContainerViewCell.reuseIdentifier
            )
            
            collectionView.dataSource = self
            collectionView.delegate = self
        }
        
        private func makeLayout() -> UICollectionViewCompositionalLayout {
            return UICollectionViewCompositionalLayout { sectionIndex, env in
                if sectionIndex == 0 {
                    let itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(200)
                    )
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
                    return NSCollectionLayoutSection(group: group)
                } else {
                    let galleryHeight = Gallery.SectionViewCell.calculatedContentHeight(for: env.container.effectiveContentSize.width,
                                                                                        itemCount: self.viewModel.previews.count)
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(galleryHeight))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
                    let section = NSCollectionLayoutSection(group: group)

                    let combinedHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(88))
                    let combinedHeader = NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: combinedHeaderSize,
                        elementKind: UICollectionView.elementKindSectionHeader,
                        alignment: .top
                    )
                    combinedHeader.pinToVisibleBounds = true
                    section.boundarySupplementaryItems = [combinedHeader]
                    return section
                }
            }
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

        @objc func handleUserInfo() {
            print("User info tapped")
            // navigate to profile
        }

        @objc func handleFollow() {
            print("Follow tapped")
            // follow logic
        }
    }
}

extension ProfileFeature.UI.ViewController.ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    private static let scrollVelocityThreshold: CGFloat = 2000
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileInfoViewCell.reuseIdentifier, for: indexPath) as! ProfileInfoViewCell
//            cell.configure(with: user)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionHeader {
            view.layer.zPosition = 2
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Gallery.MenuTabViewCell.reuseIdentifier, for: indexPath) as! Gallery.MenuTabViewCell
//        header.configure(categories: categories,
//                         selectedCategory: selectedCategoryIndex,
//                         sorts: ["Recent", "Most Viewed", "Pinned", "Album 1", "Album 2"],
//                         selectedSort: 0)
//        header.onCategorySelected = { [weak self] index in
//            self?.selectedCategoryIndex = index
//            if let galleryCell = self?.collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? Gallery.ContainerViewCell {
//                galleryCell.scrollToPage(index)
//                self?.collectionView.collectionViewLayout.invalidateLayout()
//            }
//        }
//        header.onSortSelected = { index in
//            print("Tri sélectionné : \(index)")
//            // TODO: Recharger les données triées
//        }
//        return header
//    }
}

extension ProfileFeature.UI.ViewController.ProfileViewController: NavigationStackFeature.UI.Overlay.NavigationStackOverlayConfigurable {
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
            rightItems: nil
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
