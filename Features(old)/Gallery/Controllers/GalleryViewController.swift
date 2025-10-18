//
//  GalleryViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 20/06/2025.
//

import UIKit
import AVFoundation

struct GalleryItem: Identifiable {
    var id: String { media.id.uuidString }
    let media: MediaContent
    var post: Post.Model
}

final class GalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    
    let galleryView = GalleryView()
    private var topItems: [GalleryItem]
    private var gridItems: [GalleryItem]
    var customSafeAreaInsets: UIEdgeInsets = .zero
    var posts: [Post.Model]
    weak var coordinator: FeedCoordinatorDelegate?
    
    // MARK: - Init
    init(posts: [Post.Model]) {
        var items: [GalleryItem] = []
        for post in posts {
            switch post.content {
            case .media(let media):
                items.append(GalleryItem(media: media, post: post))
            case .gallery(let medias):
                items += medias.map { GalleryItem(media: $0, post: post) }
            }
        }
        let top = Array(items.prefix(6))
        let grid = Array(items.dropFirst(6))
        self.topItems = top
        self.gridItems = grid
        self.posts = posts
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func loadView() { view = galleryView }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.contentInsetAdjustmentBehavior = .never
        galleryView.customSafeArea = customSafeAreaInsets
        collectionView.contentInset = customSafeAreaInsets
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = Self.makeLayout()
        collectionView.register(GalleryCell.self, forCellWithReuseIdentifier: "GalleryCell")
        collectionView.register(
            GallerySectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: GallerySectionHeaderView.reuseIdentifier
        )
        galleryView.backgroundColor = .white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let offset: CGFloat = 8
        let headerHeight = galleryView.headerView.frame.height
        let safeBottom = view.safeAreaInsets.bottom + offset

        // TOP inset
        if collectionView.contentInset.top != headerHeight + offset {
            collectionView.contentInset.top = headerHeight + offset
            collectionView.verticalScrollIndicatorInsets.top = headerHeight + offset
        }

        // BOTTOM inset
        if collectionView.contentInset.bottom != safeBottom {
            collectionView.contentInset.bottom = safeBottom
            collectionView.verticalScrollIndicatorInsets.bottom = safeBottom
        }
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        galleryView.customSafeArea = view.safeAreaInsets
    }
    
    // MARK: - Sections & Data
    enum Section: Int, CaseIterable {
        case grid = 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gridItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        let item = gridItems[indexPath.item]
        
        let layoutPattern: [Bool] = [true, false, false, false, false, true, true, false, false, false, true]
        let radius: CGFloat = 8
        let isLargeCell = layoutPattern[indexPath.item % layoutPattern.count]
        
        cell.configure(with: item.media)
        cell.applyCornerRadius(radius)
        cell.isLarge = isLargeCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? GalleryCell else { return }
        guard let feedContainer = self.parent as? FeedContainerViewController else { return }
        
        let item = gridItems[indexPath.item]
        feedContainer.presentFeedFromGallery(cell, post: item.post, media: item.media, from: indexPath)
    }
    
    // MARK: - Layout
    static func makeLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { section, env in
            let cellSpacing: CGFloat = 4
            let horizontalInset: CGFloat = cellSpacing
            
            // === Grille unique ===
            let isCellLarge: [Bool] = [true, false, false, false, false, true, true, false, false, false, true]
            
            let columns: CGFloat = 3
            let totalSpacing = (columns - 1) * cellSpacing + 2 * horizontalInset
            let cellWidth = (env.container.effectiveContentSize.width - totalSpacing) / columns
            let cellHeight = cellWidth
            let groupHeight = cellHeight * 5 + cellSpacing * 4
            
            let group = NSCollectionLayoutGroup.custom(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(groupHeight)
                )
            ) { _ in
                var frames: [NSCollectionLayoutGroupCustomItem] = []
                
                for i in 0..<isCellLarge.count {
                    let frame: CGRect
                    switch i {
                    case 0:
                        frame = CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight * 2 + cellSpacing)
                    case 1:
                        frame = CGRect(x: cellWidth + cellSpacing, y: 0, width: cellWidth, height: cellHeight)
                    case 2:
                        frame = CGRect(x: 2 * (cellWidth + cellSpacing), y: 0, width: cellWidth, height: cellHeight)
                    case 3:
                        frame = CGRect(x: cellWidth + cellSpacing, y: cellHeight + cellSpacing, width: cellWidth, height: cellHeight)
                    case 4:
                        frame = CGRect(x: 2 * (cellWidth + cellSpacing), y: cellHeight + cellSpacing, width: cellWidth, height: cellHeight)
                    case 5:
                        frame = CGRect(x: 0, y: 2 * (cellHeight + cellSpacing), width: 2 * cellWidth + cellSpacing, height: cellHeight)
                    case 6:
                        frame = CGRect(x: 2 * (cellWidth + cellSpacing), y: 2 * (cellHeight + cellSpacing), width: cellWidth, height: cellHeight * 2 + cellSpacing)
                    case 7:
                        frame = CGRect(x: 0, y: 3 * (cellHeight + cellSpacing), width: cellWidth, height: cellHeight)
                    case 8:
                        frame = CGRect(x: cellWidth + cellSpacing, y: 3 * (cellHeight + cellSpacing), width: cellWidth, height: cellHeight)
                    case 9:
                        frame = CGRect(x: 0, y: 4 * (cellHeight + cellSpacing), width: cellWidth, height: cellHeight)
                    case 10:
                        frame = CGRect(x: cellWidth + cellSpacing, y: 4 * (cellHeight + cellSpacing), width: 2 * cellWidth + cellSpacing, height: cellHeight)
                    default:
                        frame = .zero
                    }
                    frames.append(NSCollectionLayoutGroupCustomItem(frame: frame))
                }
                
                return frames
            }
            
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.interGroupSpacing = cellSpacing
            sectionLayout.contentInsets = .init(top: 0, leading: horizontalInset, bottom: 0, trailing: horizontalInset)
            return sectionLayout
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // Priorise le dismiss UNIQUEMENT sur swipe franchement horizontal
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = pan.velocity(in: pan.view)
        let isHorizontal = abs(velocity.x) > abs(velocity.y) && velocity.x > 0
        
        // 1. Si pas un swipe horizontal, pas de dismiss
        if !isHorizontal { return false }
        
        // 2. On détecte la position du touch dans la collection
        let location = pan.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: location) {
            if indexPath.section == 0 {
                // Si on swipe dans la section 0 (carrousel horizontal) => on ne trigger PAS le dismiss
                return false
            }
        }
        return true
    }
    
    var collectionView: UICollectionView {
        return galleryView.collectionView
    }
    
    func dettachMediaView(at indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? GalleryCell {
            cell.mediaView.removeFromSuperview()
        }
    }
    
    func scrollToItemIfNeeded(at indexPath: IndexPath) {
        let safeIndexPath = IndexPath(item: indexPath.item, section: 0)
        
        guard collectionView.numberOfItems(inSection: safeIndexPath.section) > safeIndexPath.item else {
            print("❌ [GalleryVC](scrollToItemIfNeeded) IndexPath hors-bounds :", safeIndexPath)
            return
        }
        guard let cell = collectionView.cellForItem(at: safeIndexPath) else {
            print("❌ [GalleryVC](scrollToItemIfNeeded) Cell not found at", safeIndexPath)
            return
        }
        
        // Repère global (dans self.view)
        let cellFrameInView = cell.convert(cell.bounds, to: view)
        let cellTopInView = cellFrameInView.minY
        let cellBottomInView = cellFrameInView.maxY
        
        let headerMaxY = galleryView.headerView.frame.maxY
        let viewHeight = view.bounds.height
        
        // Cas 1 : cellule sous le header sticky
        let isUnderStickyHeader = cellTopInView < headerMaxY && cellBottomInView > headerMaxY
        
        // Cas 2 : cellule partiellement ou totalement hors bas de l’écran
        let isPartiallyOrFullyBelow = cellBottomInView > viewHeight
        
        if isUnderStickyHeader {
            let desiredOffsetY = collectionView.contentOffset.y + (cellFrameInView.minY - headerMaxY)
            collectionView.setContentOffset(CGPoint(x: 0, y: desiredOffsetY), animated: false)
            collectionView.layoutIfNeeded()
        } else if isPartiallyOrFullyBelow {
            let cellVisibleHeight = viewHeight - headerMaxY
            let desiredOffsetY = collectionView.contentOffset.y + (cellBottomInView - (headerMaxY + cellVisibleHeight))
            collectionView.setContentOffset(CGPoint(x: 0, y: desiredOffsetY), animated: false)
            collectionView.layoutIfNeeded()
        }
    }
    
    func updateGalleryItem(at indexPath: IndexPath, with post: Post.Model, media: MediaContent) {
        let updatedItem = GalleryItem(media: media, post: post)
        guard gridItems.indices.contains(indexPath.item) else { return }
        gridItems[indexPath.item] = updatedItem
        collectionView.reloadItems(at: [indexPath])
    }
    
    func updateCurrentPlayingVideos(forcePlayCell: GalleryCell? = nil) {
        let visibleCells = sortedStableCellsByProximityToCenter()
        let manager = VideoPlayerManager.shared
        let poolCapacity = manager.playerPool.count
        
        // 1. Filtrer uniquement les `isLarge`
        var candidates = visibleCells.filter { $0.isLarge }

        // 2. Ajouter la cellule forcée si présente et pas déjà dans la liste
        if let forced = forcePlayCell {
            if !candidates.contains(where: { $0 === forced }) {
                candidates.insert(forced, at: 0)
            }
        }

        // 3. Limiter au pool
        let toPlay = Array(candidates.prefix(poolCapacity))
        let toPlayIds = Set(toPlay.compactMap { $0.mediaView.currentMedia?.id.uuidString })

        // 4. Libère les players hors champ
        for (mediaId, _) in manager.assignments {
            if !toPlayIds.contains(mediaId) {
                manager.releasePlayer(for: mediaId)
            }
        }

        // 5. Jouer ou assigner les vidéos
        for cell in toPlay {
            guard let media = cell.mediaView.currentMedia else { continue }
            let videoId = media.id.uuidString
            let isForced = (cell === forcePlayCell)

            if let assigned = manager.assignedPlayer(for: videoId) {
                cell.mediaView.showVideoPlayer(assigned)
            } else if manager.assignments.count >= poolCapacity {
                let mediaToReplace = findFarthestVisibleMediaVertically(excluding: videoId, mustBeLargeCell: !isForced)
                if let mediaToReplace {
                    cell.mediaView.migratePlayer(to: media, from: mediaToReplace)
                }
            } else {
//                cell.mediaView.assignNewPlayer(for: media)
                cell.mediaView.assignPlayer()
            }
        }
    }
    
    private func findFarthestVisibleMediaVertically(excluding excludedVideoId: String? = nil, mustBeLargeCell: Bool = false) -> MediaContent? {
        guard let attributes = collectionView.collectionViewLayout
            .layoutAttributesForElements(in: collectionView.bounds),
              let window = collectionView.window
        else { return nil }
        
        let centerY = collectionView.convert(collectionView.bounds.center, to: window).y
        
        var farthestMedia: MediaContent?
        var maxDistance: CGFloat = -1
        
        for attr in attributes {
            guard let cell = collectionView.cellForItem(at: attr.indexPath) as? GalleryCell,
                  cell.window != nil,
                  cell.bounds.height > 0,
                  let media = cell.mediaView.currentMedia
            else { continue }
            
            if mustBeLargeCell && !cell.isLarge {
                continue
            }
            
            if let excludedId = excludedVideoId,
               media.id.uuidString == excludedId {
                continue
            }
            
            let cellCenterY = cell.convert(cell.bounds.center, to: window).y
            let distance = abs(cellCenterY - centerY)
            
            if distance > maxDistance {
                maxDistance = distance
                farthestMedia = media
            }
        }
        
        return farthestMedia
    }
    
    private func findFarthestVisibleAssignedMediaId(excluding newMediaId: String) -> String? {
        guard let superview = collectionView.superview else { return nil }
        
        let headerHeight = galleryView.headerView.frame.height
        let visibleCenter = CGPoint(
            x: collectionView.bounds.midX,
            y: collectionView.bounds.midY + headerHeight / 2
        )
        let visibleCenterInSuperview = collectionView.convert(visibleCenter, to: superview)
        
        var farthest: (mediaId: String, distance: CGFloat)? = nil
        
        for cell in collectionView.visibleCells.compactMap({ $0 as? GalleryCell }) {
            guard
                let media = cell.mediaView.currentMedia,
                media.id.uuidString != newMediaId,
                VideoPlayerManager.shared.isPlayerAssigned(for: media.id.uuidString)
            else { continue }
            
            let cellCenter = cell.convert(cell.bounds.center, to: superview)
            let distance = hypot(cellCenter.x - visibleCenterInSuperview.x, cellCenter.y - visibleCenterInSuperview.y)
            
            if farthest == nil || distance > farthest!.distance {
                farthest = (media.id.uuidString, distance)
            }
        }
        
        return farthest?.mediaId
    }
    
    private func sortedStableCellsByProximityToCenter() -> [GalleryCell] {
        guard let superview = collectionView.superview else { return [] }
        
        let headerHeight = galleryView.headerView.frame.height
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
    
    func playOnlyGalleryCell(_ cell: GalleryCell) {
        let visibleCells = collectionView.visibleCells.compactMap { $0 as? GalleryCell }
        for c in visibleCells {
            guard let media = c.mediaView.currentMedia else { continue }
            let videoId = media.id.uuidString
            if c === cell {
                assignPlayerIfNeeded(to: c, for: media)
                c.mediaView.layoutIfNeeded()
                if let pv = c.mediaView.videoPlayerView {
                    pv.setNeedsLayout()
                    pv.layoutIfNeeded()
                    (pv.layer as? AVPlayerLayer)?.setNeedsLayout()
                    (pv.layer as? AVPlayerLayer)?.layoutIfNeeded()
                    (pv.layer as? AVPlayerLayer)?.frame = pv.bounds
                    c.mediaView.debugInfo()
                }
                c.mediaView.debugInfo()
            } else {
                VideoPlayerManager.shared.releasePlayer(for: videoId)
                c.mediaView.hideVideoPlayer()
                c.mediaView.display(media: media)
            }
        }
    }
    
    func assignPlayerIfNeeded(to cell: GalleryCell, for media: MediaContent) {
        guard media.isVideo else {
            cell.mediaView.hideVideoPlayer()
            cell.mediaView.display(media: media)
            return
        }
        let videoId = media.id.uuidString
        if let player = VideoPlayerManager.shared.assignedPlayer(for: videoId) {
            cell.mediaView.showVideoPlayer(player)
            return
        }
        if let url = media.url, let player = VideoPlayerManager.shared.assignPlayer(for: videoId, url: url) {
            cell.mediaView.showVideoPlayer(player)
        } else {
            cell.mediaView.hideVideoPlayer()
            cell.mediaView.display(media: media)
        }
    }
}


private enum AssociatedKeys {
    static var scrollOffset: UInt8 = 0
    static var scrollTime: UInt8 = 0
}

extension GalleryViewController: UIScrollViewDelegate {
    private static let scrollVelocityThreshold: CGFloat = 2000
    
    private var lastScrollOffset: CGFloat {
        get { objc_getAssociatedObject(self, &AssociatedKeys.scrollOffset) as? CGFloat ?? 0 }
        set { objc_setAssociatedObject(self, &AssociatedKeys.scrollOffset, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    private var lastScrollTime: TimeInterval {
        get { objc_getAssociatedObject(self, &AssociatedKeys.scrollTime) as? TimeInterval ?? 0 }
        set { objc_setAssociatedObject(self, &AssociatedKeys.scrollTime, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let now = CACurrentMediaTime()
        let deltaY = scrollView.contentOffset.y - lastScrollOffset
        let deltaTime = now - lastScrollTime
        let velocity = abs(deltaY / max(deltaTime, 0.001))
        
        lastScrollOffset = scrollView.contentOffset.y
        lastScrollTime = now
        
        if velocity < Self.scrollVelocityThreshold {
            updateCurrentPlayingVideos()
        }
        
        guard let firstCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) else { return }
        let firstCellFrame = firstCell.convert(firstCell.bounds, to: view)
        let headerViewMaxY = galleryView.headerView.convert(galleryView.headerView.bounds, to: view).maxY
        
        let transitionRange: CGFloat = 16
        let offset = headerViewMaxY - firstCellFrame.minY
        let progress = min(max(offset / transitionRange, 0), 1)
        galleryView.headerView.blurAlpha = progress
    }
    
    private func visibleSectionHeaderView(forSection section: Int) -> UICollectionReusableView? {
        let visibleHeaders = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader)
        return visibleHeaders.first(where: {
            if let indexPath = collectionView.indexPath(forSupplementaryView: $0), indexPath.section == section {
                return true
            }
            return false
        })
    }
}
