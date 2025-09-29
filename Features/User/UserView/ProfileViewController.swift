//
//  UserProfileViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 24/07/2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    var onDismiss: (() -> Void)?
    
    // MARK: - Views
    private let headerView = UserHeaderView()
    private let bannerView = UIView()
    private let bannerImageView = UIImageView()
    private let bannerOverlayView = UIView()
    private let bannerSystemOverlay = UIView()
    private var collectionView: UICollectionView!
    private let categories = ["square.grid.3x3", "arrow.2.squarepath", "bubble.left.and.text.bubble.right", "music.note.list"]
    
    // MARK: - State
    private var selectedCategoryIndex = 0
    private weak var tabsHeader: Gallery.HeaderView?
    private let user: User
    
    // Contraintes dynamiques
    private var bannerHeightConstraint: NSLayoutConstraint!

    // MARK: - Init
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupBanner()
        setupHeader()
        view.backgroundColor = .white
        view.clipsToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let attributes = collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: 0)) {
            let frameInView = collectionView.convert(attributes.frame, to: view)
            bannerHeightConstraint.constant = max(frameInView.maxY, 100)
        }

        let headerHeight = headerView.frame.height
        if collectionView.contentInset.top != headerHeight {
            collectionView.contentInset.top = headerHeight
            collectionView.verticalScrollIndicatorInsets.top = headerHeight
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss?()
    }
    
    private func setupHeader() {
        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        headerView.backButton.addAction(UIAction(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
    }
    

    private func setupBanner() {
        bannerImageView.contentMode = .scaleAspectFill
        bannerImageView.clipsToBounds = true
        bannerImageView.translatesAutoresizingMaskIntoConstraints = false
        bannerImageView.image = UIImage(named: "kazetachinu001")
        view.addSubview(bannerImageView)
        view.sendSubviewToBack(bannerImageView)

        // --- Overlay sombre ---
        bannerOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        bannerOverlayView.translatesAutoresizingMaskIntoConstraints = false
        bannerImageView.addSubview(bannerOverlayView)
        
        bannerSystemOverlay.backgroundColor = .systemBackground
        bannerSystemOverlay.alpha = 0 // invisible par défaut
        bannerSystemOverlay.translatesAutoresizingMaskIntoConstraints = false
        bannerImageView.addSubview(bannerSystemOverlay)

        bannerHeightConstraint = bannerImageView.heightAnchor.constraint(equalToConstant: 200)
        NSLayoutConstraint.activate([
            bannerImageView.topAnchor.constraint(equalTo: view.topAnchor),
            bannerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerHeightConstraint,
            bannerOverlayView.topAnchor.constraint(equalTo: bannerImageView.topAnchor),
            bannerOverlayView.leadingAnchor.constraint(equalTo: bannerImageView.leadingAnchor),
            bannerOverlayView.trailingAnchor.constraint(equalTo: bannerImageView.trailingAnchor),
            bannerOverlayView.bottomAnchor.constraint(equalTo: bannerImageView.bottomAnchor),
            bannerSystemOverlay.topAnchor.constraint(equalTo: bannerImageView.topAnchor),
            bannerSystemOverlay.leadingAnchor.constraint(equalTo: bannerImageView.leadingAnchor),
            bannerSystemOverlay.trailingAnchor.constraint(equalTo: bannerImageView.trailingAnchor),
            bannerSystemOverlay.bottomAnchor.constraint(equalTo: bannerImageView.bottomAnchor)
        ])
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        headerView.topPadding = view.safeAreaInsets.top
    }
    
    private func setupCollectionView() {
        let layout = makeLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        view.insertSubview(collectionView, aboveSubview: bannerView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionView.register(UserInfoCell.self, forCellWithReuseIdentifier: "UserInfoCell")
        collectionView.register(Gallery.Pages.self, forCellWithReuseIdentifier: Gallery.Pages.reuseIdentifier)
        collectionView.register(Gallery.HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Gallery.HeaderView.reuseIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - Blur Update
    private func updateHeaderBlur(_ scrollView: UIScrollView) {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? UserInfoCell else { return }
        guard let userInfoAttributes = collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: 0)) else { return }

        // Frames dans la vue principale
        let usernameFrame = cell.convert(cell.usernameFrameInContentView, to: view)
        let userInfoFrame = collectionView.convert(userInfoAttributes.frame, to: view)
        let headerBottomY = headerView.frame.maxY

        // Repères
        let start = usernameFrame.maxY        // début du blur (bas du username)
        let end = userInfoFrame.maxY          // fin du blur (bas de la section)

        // Progression : 0 si au-dessus, 1 si totalement en dessous
        let rawProgress = (headerBottomY - start) / (end - start)
        let progress = max(0, min(1, rawProgress))
        
        headerView.blurAlpha = progress
    }
}

// MARK: - Layout
extension ProfileViewController {
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, env in
            guard let self = self else { return nil }
            if sectionIndex == 0 {
                // === Section User Info ===
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(400)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
                return NSCollectionLayoutSection(group: group)
            } else {
                // === Section Gallery ===
                let dynamicHeight: CGFloat = {
                    if let galleryCell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? Gallery.Pages {
                        return galleryCell.currentPageHeight()
                    }
                    return env.container.contentSize.height
                }()
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(dynamicHeight))
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
}

// MARK: - DataSource
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserInfoCell", for: indexPath) as! UserInfoCell
            cell.configure(with: user)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Gallery.Pages.reuseIdentifier, for: indexPath) as! Gallery.Pages
            cell.configure(categories: categories, posts: user.posts) { [weak self] in
                self?.collectionView.collectionViewLayout.invalidateLayout()
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Gallery.HeaderView.reuseIdentifier, for: indexPath) as! Gallery.HeaderView
        header.configure(categories: categories,
                         selectedCategory: selectedCategoryIndex,
                         sorts: ["Recent", "Most Viewed", "Pinned", "Album 1", "Album 2"],
                         selectedSort: 0)
        header.onCategorySelected = { [weak self] index in
            self?.selectedCategoryIndex = index
            if let galleryCell = self?.collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? Gallery.Pages {
                galleryCell.scrollToPage(index)
                self?.collectionView.collectionViewLayout.invalidateLayout()
            }
        }
        header.onSortSelected = { index in
            print("Tri sélectionné : \(index)")
            // TODO: Recharger les données triées
        }
        return header
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? UserInfoCell {
            let bioFrame = cell.convert(cell.bioFrameFrameInContentView, to: view)
            let headerBottomY = headerView.frame.maxY

            let isUnderHeader = bioFrame.maxY <= headerBottomY
            let targetColor: UIColor = isUnderHeader ? .black : .white

            headerView.setBackButtonColor(targetColor, animated: true)
            headerView.setFollowButtonVisible(isUnderHeader, animated: true)
        }

        if let attributes = collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: 0)) {
            let frameInView = collectionView.convert(attributes.frame, to: view)
            bannerHeightConstraint.constant = max(frameInView.maxY, 100)
        }

        if let userInfoAttributes = collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: 0)) {
            let userInfoFrame = collectionView.convert(userInfoAttributes.frame, to: view)
            let headerBottomY = headerView.frame.maxY
            
            // --- Blur du header ---
            let startY = userInfoFrame.maxY - 64
            let endY = userInfoFrame.maxY
            let rawProgress = (headerBottomY - startY) / (endY - startY)
            let progress = max(0, min(1, rawProgress))
            headerView.updateBlurProgress(progress)
            
            // --- Opacité de la bannière vers systemBackground ---
            bannerSystemOverlay.alpha = progress
        }

        updateHeaderBlur(scrollView)
    }
}
