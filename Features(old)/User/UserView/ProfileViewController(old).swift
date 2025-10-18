//
//  UserProfileViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 24/07/2025.
//

import UIKit

final class ProfileViewController: UIViewController, CollectionViewContainer {
    var onDismiss: (() -> Void)?
    
    // MARK: - Views
    private let headerView = ProfileHeaderView()
    private let headerBlurGradientView = CAGradientLayer()
    private let bannerMediaView = MediaContainerView(usesStandalonePlayer: true)
    private let bannerOverlayView = UIView()
    private let bannerSystemOverlay = UIView()
    var collectionView: UICollectionView
    private let categories = ["square.grid.3x3", "arrow.2.squarepath", "bubble.left.and.text.bubble.right", "music.note.list"]
    var onMediaTapped: OnGalleryTap?
    
    private let blurOverlayView: UIVisualEffectView = {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.alpha = 0 // contrôlé par le scroll
        return blur
    }()
    
//    private let blurGradientMask: CAGradientLayer = {
//        let gradient = CAGradientLayer()
//        gradient.startPoint = CGPoint(x: 0.5, y: 0)
//        gradient.endPoint = CGPoint(x: 0.5, y: 1)
//        
//        // Opaque sur toute la hauteur
//        gradient.colors = [
//            UIColor.black.cgColor,
//            UIColor.black.cgColor
//        ]
//        gradient.locations = [0, 1]
//        
//        return gradient
//    }()
    
    private var blurHeightConstraint: NSLayoutConstraint!
    
    // MARK: - State
    private var selectedCategoryIndex = 0
    private weak var tabsHeader: Gallery.MenuTabViewCell?
    var viewModel: GalleryViewModel
    private var user: User { viewModel.user }
    private var selectedPost: Post.Model?
    private var bannerMedia: MediaContent?
    private var galleryHasPassedHalf = false
    private var didAssignBannerPlayer = false
    
    // Contraintes dynamiques
    private var bannerHeightConstraint: NSLayoutConstraint!

    // MARK: - Init
    init(user: User) {
        self.viewModel = GalleryViewModel(user: user)
        
        let layout = UICollectionViewFlowLayout()
        self.collectionView = FeedCollectionView(frame: .zero, collectionViewLayout: layout)
        
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
        }
        
        let tabMenuHeight: CGFloat = 44
        
        // Ajuster la hauteur totale du blur
        blurHeightConstraint.constant = headerHeight + tabMenuHeight
        headerBlurGradientView.frame = blurOverlayView.bounds
        
        // Pourcentage d'opacité complète (jusqu'à headerHeight)
        let opaqueRatio = headerHeight / blurHeightConstraint.constant

        // Locations :
        // - 0.0   -> opaque
        // - opaqueRatio -> opaque (fin du header)
        // - 1.0   -> transparent (fin du tabMenuHeight)
        headerBlurGradientView.colors = [
            UIColor.black.cgColor,
            UIColor.black.cgColor,
            UIColor.black.withAlphaComponent(0).cgColor
        ]
        headerBlurGradientView.locations = [
            0,
            NSNumber(value: Float(opaqueRatio)),
            1
        ]
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        headerView.topPadding = view.safeAreaInsets.top
        collectionView.contentInset.bottom = view.safeAreaInsets.bottom
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCurrentPlayingVideos()
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
        headerView.onBackTapped = { [weak self] in
            self?.dismiss(animated: true)
        }
        headerView.configure(with: user)
        
        // header gradient blur
        headerBlurGradientView.startPoint = CGPoint(x: 0.5, y: 0)
        headerBlurGradientView.endPoint = CGPoint(x: 0.5, y: 1)
        headerBlurGradientView.colors = [
            UIColor.black.cgColor,
            UIColor.black.cgColor
        ]
        headerBlurGradientView.locations = [0, 1]
        
        collectionView.addSubview(blurOverlayView)
        collectionView.bringSubviewToFront(blurOverlayView)
        blurOverlayView.layer.zPosition = 1
        blurHeightConstraint = blurOverlayView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            blurOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            blurOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurHeightConstraint
        ])
        blurOverlayView.layer.mask = headerBlurGradientView
    }
    

    private func setupBanner() {
        bannerMediaView.clipsToBounds = true
        bannerMediaView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerMediaView)
        view.sendSubviewToBack(bannerMediaView)

        // --- Overlay sombre ---
        bannerOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        bannerOverlayView.translatesAutoresizingMaskIntoConstraints = false
        bannerMediaView.addSubview(bannerOverlayView)
        
        bannerSystemOverlay.backgroundColor = .systemBackground
        bannerSystemOverlay.alpha = 0 // invisible par défaut
        bannerSystemOverlay.translatesAutoresizingMaskIntoConstraints = false
        bannerMediaView.addSubview(bannerSystemOverlay)

        bannerHeightConstraint = bannerMediaView.heightAnchor.constraint(equalToConstant: 200)
        NSLayoutConstraint.activate([
            bannerMediaView.topAnchor.constraint(equalTo: view.topAnchor),
            bannerMediaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerMediaView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerHeightConstraint,
            bannerOverlayView.topAnchor.constraint(equalTo: bannerMediaView.topAnchor),
            bannerOverlayView.leadingAnchor.constraint(equalTo: bannerMediaView.leadingAnchor),
            bannerOverlayView.trailingAnchor.constraint(equalTo: bannerMediaView.trailingAnchor),
            bannerOverlayView.bottomAnchor.constraint(equalTo: bannerMediaView.bottomAnchor),
            bannerSystemOverlay.topAnchor.constraint(equalTo: bannerMediaView.topAnchor),
            bannerSystemOverlay.leadingAnchor.constraint(equalTo: bannerMediaView.leadingAnchor),
            bannerSystemOverlay.trailingAnchor.constraint(equalTo: bannerMediaView.trailingAnchor),
            bannerSystemOverlay.bottomAnchor.constraint(equalTo: bannerMediaView.bottomAnchor)
        ])

        configureBannerMedia()
    }
    
    private func configureBannerMedia() {
        guard let original = user.posts.first?.firstMedia else {
            print("⚠️ Aucun média disponible pour la bannière")
            return
        }

        // Duplique le média avec un nouvel ID pour la bannière
        let duplicated = original.duplicatedWithNewId()
        bannerMedia = duplicated
        bannerMediaView.display(media: duplicated)

        if duplicated.isVideo {
            bannerMediaView.assignStandalonePlayer(for: duplicated)
        }
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
    
    // MARK: - Blur Update
    private func updateHeaderBlur(_ scrollView: UIScrollView) {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? ProfileInfoViewCell else { return }
        guard let userInfoAttributes = collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: 0)) else { return }

        // Frames dans la vue principale
        let usernameFrame = cell.convert(cell.nameFrameInContentView, to: view)
        let userInfoFrame = collectionView.convert(userInfoAttributes.frame, to: view)
        let headerBottomY = headerView.frame.maxY

        // Repères
        let start = usernameFrame.maxY        // début du blur (bas du username)
        let end = userInfoFrame.maxY          // fin du blur (bas de la section)

        // Progression : 0 si au-dessus, 1 si totalement en dessous
        let rawProgress = (headerBottomY - start) / (end - start)
        let progress = max(0, min(1, rawProgress))
        
        blurOverlayView.alpha = progress
    }
    
    private var isBannerVisible: Bool {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? ProfileInfoViewCell else { return true }
        let bioFrame = cell.convert(cell.bioFrameFrameInContentView, to: view)
        let headerBottomY = headerView.frame.maxY
        return bioFrame.maxY > headerBottomY
    }
}

// MARK: - Layout
extension ProfileViewController {
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
                                                                                    itemCount: self.user.posts.count)
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
}

private enum AssociatedKeys {
    static var scrollOffset: UInt8 = 0
    static var scrollTime: UInt8 = 0
}

// MARK: - DataSource
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    private static let scrollVelocityThreshold: CGFloat = 2000
    
    private var lastScrollOffset: CGFloat {
        get { objc_getAssociatedObject(self, &AssociatedKeys.scrollOffset) as? CGFloat ?? 0 }
        set { objc_setAssociatedObject(self, &AssociatedKeys.scrollOffset, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    private var lastScrollTime: TimeInterval {
        get { objc_getAssociatedObject(self, &AssociatedKeys.scrollTime) as? TimeInterval ?? 0 }
        set { objc_setAssociatedObject(self, &AssociatedKeys.scrollTime, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileInfoViewCell.reuseIdentifier, for: indexPath) as! ProfileInfoViewCell
            cell.configure(with: user)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Gallery.ContainerViewCell.reuseIdentifier, for: indexPath) as! Gallery.ContainerViewCell
            cell.viewModel = viewModel
            cell.configure(categories: categories)
            cell.onMediaTapped = { [weak self] ctx in
                self?.selectedPost = ctx.item.post
                self?.onMediaTapped?(ctx)
            }
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Gallery.MenuTabViewCell.reuseIdentifier, for: indexPath) as! Gallery.MenuTabViewCell
        header.configure(categories: categories,
                         selectedCategory: selectedCategoryIndex,
                         sorts: ["Recent", "Most Viewed", "Pinned", "Album 1", "Album 2"],
                         selectedSort: 0)
        header.onCategorySelected = { [weak self] index in
            self?.selectedCategoryIndex = index
            if let galleryCell = self?.collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? Gallery.ContainerViewCell {
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
        
        let now = CACurrentMediaTime()
        let deltaY = scrollView.contentOffset.y - lastScrollOffset
        let deltaTime = now - lastScrollTime
        let velocity = abs(deltaY / max(deltaTime, 0.001))
        
        lastScrollOffset = scrollView.contentOffset.y
        lastScrollTime = now
        
        handleGalleryCrossingIfNeeded()
        
        if galleryHasPassedHalf && velocity < Self.scrollVelocityThreshold {
            updateCurrentPlayingVideos()
        }
        
        if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? ProfileInfoViewCell {
            let bioFrame = cell.convert(cell.bioFrameFrameInContentView, to: view)
            let headerBottomY = headerView.frame.minY

            let isUnderHeader = bioFrame.maxY <= headerBottomY
            let targetColor: UIColor = isUnderHeader ? .black : .white

            headerView.setBackButtonColor(targetColor, animated: true)
            headerView.setInfoVisible(isUnderHeader, animated: true)
            
            // --- Pause / Lecture de la bannière ---
            if let media = bannerMedia, media.isVideo {
                if isUnderHeader {
                    bannerMediaView.pauseVideoPlayer()
                } else {
                    bannerMediaView.playVideoPlayer()
                }
            }
        }

        if let attributes = collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: 0)) {
            let frameInView = collectionView.convert(attributes.frame, to: view)
            bannerHeightConstraint.constant = max(frameInView.maxY, 100)
        }

        if let profileInfoAttributes = collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: 0)) {
            let profileInfoFrame = collectionView.convert(profileInfoAttributes.frame, to: view)
            let headerBottomY = headerView.frame.maxY
            
            // Distance totale sur laquelle le blur progresse
            let triggerDistance: CGFloat = 120
            let endY = profileInfoFrame.maxY
            let startY = endY - triggerDistance

            // Progression exponentielle
            let rawProgress = (headerBottomY - startY) / (endY - startY)
            let normalized = max(0, min(1, rawProgress))
            let progress = pow(normalized, 10)
            headerView.updateBlurProgress(progress)
            bannerSystemOverlay.alpha = progress
            
            // --- Gestion du gradient de blur ---
            if progress >= 1 {
                // Complètement opaque
                headerBlurGradientView.colors = [
                    UIColor.black.cgColor,
                    UIColor.black.cgColor,
                    UIColor.black.cgColor
                ]
                headerBlurGradientView.locations = [0, 1, 1]
            } else {
                headerBlurGradientView.colors = [
                    UIColor.black.cgColor,
                    UIColor.black.cgColor
                ]
                headerBlurGradientView.locations = [
                    0,
                    1
                ]
            }
        }

        updateHeaderBlur(scrollView)
    }
    
    func updateCurrentPlayingVideos(forcePlayCell: Gallery.ViewCell? = nil) {
        guard
            let galleryContainerCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? Gallery.ContainerViewCell,
            let currentSection = galleryContainerCell.currentVisibleSectionCell()
        else { return }

        let visibleGalleryCells = currentSection.visibleGalleryCellsSortedByProximity(to: view)
        let manager = VideoPlayerManager.shared
        let poolCapacity = manager.playerPool.count

        var candidates = visibleGalleryCells.filter { $0.isLarge }

        if let forced = forcePlayCell, !candidates.contains(where: { $0 === forced }) {
//            candidates.insert(forced, at: 0)
        }

        let toPlay = Array(candidates.prefix(poolCapacity))
        let toPlayIds = Set(toPlay.compactMap { $0.mediaView.currentMedia?.id.uuidString })

        // --- LIBÉRATION DES NON-VISIBLES ---
        for (mediaId, player) in manager.assignments {
            if !toPlayIds.contains(mediaId) {
                manager.releasePlayer(for: mediaId)
            }
        }

        // --- ASSIGNATION DES PLAYERS ---
        for cell in toPlay {
            guard
                let media = cell.mediaView.currentMedia,
                media.isVideo,
                manager.assignedPlayer(for: media.id.uuidString) == nil,
                let url = media.url
            else { continue }

            if let player = manager.assignPlayer(for: media.id.uuidString, url: url) {
                cell.mediaView.showVideoPlayer(player)
                player.play()
            }
        }
        
        handleGalleryCrossingIfNeeded()
    }
    
    private func findFarthestVisibleMediaVertically(in candidates: [Gallery.ViewCell], excluding excludedVideoId: String?, mustBeLargeCell: Bool) -> MediaContent? {
        guard let window = view.window else { return nil }

        let centerY = view.convert(view.bounds.center, to: window).y
        var farthestMedia: MediaContent?
        var maxDistance: CGFloat = -1

        for cell in candidates {
            guard let media = cell.mediaView.currentMedia else { continue }

            if mustBeLargeCell && !cell.isLarge { continue }
            if let excluded = excludedVideoId, media.id.uuidString == excluded { continue }

            let cellCenterY = cell.convert(cell.bounds.center, to: window).y
            let distance = abs(cellCenterY - centerY)

            if distance > maxDistance {
                maxDistance = distance
                farthestMedia = media
            }
        }

        return farthestMedia
    }
    
    private func sortedStableCellsByProximityToCenter() -> [GalleryCell] {
        guard let superview = collectionView.superview else { return [] }
        
        let headerHeight = headerView.frame.height
        let visibleCenterY = collectionView.bounds.midY + headerHeight / 2
        let viewportCenter = CGPoint(x: collectionView.bounds.midX, y: visibleCenterY)
        let viewportCenterInSuperview = collectionView.convert(viewportCenter, to: superview)
        
        var scoredCells: [(cell: GalleryCell, distance: CGFloat)] = []
        
        for case let cell as GalleryCell in collectionView.visibleCells {
            guard cell.isLarge, cell.isReadyForPlayback else { continue }
            
            let cellCenterInSuperview = cell.convert(cell.bounds.center, to: superview)
            let dx = cellCenterInSuperview.x - viewportCenterInSuperview.x
            let dy = cellCenterInSuperview.y - viewportCenterInSuperview.y
            let distance = dx * dx + dy * dy
            
            scoredCells.append((cell, distance))
        }
        
        let sorted = scoredCells.sorted { $0.distance < $1.distance }
        
        return sorted.map { $0.cell }
    }
    
    private func hasGalleryPassedHalfScreen() -> Bool {
        guard let attrs = collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: 1)) else { return false }
        let frameInView = collectionView.convert(attrs.frame, to: view)
        let halfY = view.bounds.midY
        return frameInView.minY <= halfY
    }

    private func handleGalleryCrossingIfNeeded() {
        let passed = hasGalleryPassedHalfScreen()
        guard passed != galleryHasPassedHalf else { return }
        galleryHasPassedHalf = passed
        
        if passed {
            playAllGalleryVideos()
        } else {
            pauseAllGalleryVideos()
        }
    }

    private func playAllGalleryVideos() {
        if let galleryContainerCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? Gallery.ContainerViewCell,
           let currentSection = galleryContainerCell.currentVisibleSectionCell() {
            for cell in currentSection.visibleGalleryCellsSortedByProximity(to: view) {
                cell.mediaView.playVideoPlayer()
            }
        }
    }

    private func pauseAllGalleryVideos() {
        if let galleryContainerCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? Gallery.ContainerViewCell,
           let currentSection = galleryContainerCell.currentVisibleSectionCell() {
            for cell in currentSection.visibleGalleryCellsSortedByProximity(to: view) {
                cell.mediaView.pauseVideoPlayer()
            }
        }
    }
}

extension ProfileViewController: HeroViewControllable {
    func heroTransitionData() -> Any? {
        guard let post = debugUnwrap(selectedPost) else {
            return nil
        }
        return post
    }
    
    // MARK: - Helpers
    private func sectionCell() -> Gallery.SectionViewCell? {
        let sectionIndexPath = IndexPath(item: 0, section: 1)
        collectionView.layoutIfNeeded()
        
        guard let containerCell = collectionView.cellForItem(at: sectionIndexPath) as? Gallery.ContainerViewCell
        else {
            print("⚠️ [AnimSource] SectionCell introuvable → nil")
            return nil
        }
        
        return containerCell.currentVisibleSectionCell()
    }
    
    // MARK: - HeroSourceViewControllable
    func heroAnimatedView(at indexPath: IndexPath) -> UIView? {
        guard let sectionCell = sectionCell() else { return nil }
        
        sectionCell.gridCollectionView.layoutIfNeeded()
        
        if let cell = sectionCell.gridCollectionView.cellForItem(at: indexPath) as? Gallery.ViewCell {
            return cell.mediaView
        } else {
            print("⚠️ [AnimSource] Cell non visible → nil")
            return nil
        }
    }
    
    func heroContainerView(at indexPath: IndexPath) -> UIView? {
        guard let sectionCell = sectionCell() else { return nil }
        
        sectionCell.gridCollectionView.layoutIfNeeded()
        
        if let cell = sectionCell.gridCollectionView.cellForItem(at: indexPath) {
            return cell
        } else {
            print("⚠️ [AnimSource] Cell non visible → gridCollectionView")
            return sectionCell.gridCollectionView
        }
    }

    func didFinishHeroTransition(
        at indexPath: IndexPath,
        with data: Any,
        animatedView: UIView,
        phase: HeroTransitionPhase
    ) {
        guard let post = data as? Post.Model else {
            print("❌ [AnimSource] Data invalide")
            return
        }
        
        // 🔄 Mettre à jour le modèle
        viewModel.replacePost(at: indexPath.item, with: post)
        
        // 🎯 Rattacher la vue animée dans son conteneur final
        if let cell = heroContainerView(at: indexPath) as? Gallery.ViewCell,
           let mediaView = animatedView as? MediaContainerView {
            cell.attachMediaView(mediaView)
        } else if let sectionCell = sectionCell(),
                  let asyncCell = sectionCell.gridCollectionView.dequeueReusableCell(
                    withReuseIdentifier: Gallery.ViewCell.reuseIdentifier,
                    for: indexPath
                  ) as? Gallery.ViewCell {
            asyncCell.pendingMediaView = animatedView as? MediaContainerView
        }
    }
}
