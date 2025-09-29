//
//  GalleryViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 20/06/2025.
//

import UIKit

struct GalleryItem {
    let media: MediaContent
}

final class GalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    
    let galleryView = GalleryView()
    private let topItems: [GalleryItem]
    private let gridItems: [GalleryItem]
    var slideTransitioningDelegate: GallerySlideTransitioningDelegate?
    var customSafeAreaInsets: UIEdgeInsets = .zero
    
    // MARK: - Init
    init(media: [MediaContent]) {
        // 6 premiers = section 1
        let top = Array(media.prefix(6))
        let grid = Array(media.dropFirst(6))
        self.topItems = top.map { GalleryItem(media: $0) }
        self.gridItems = grid.map { GalleryItem(media: $0) }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func loadView() { view = galleryView }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        galleryView.collectionView.contentInsetAdjustmentBehavior = .never
        galleryView.customSafeAreaTop = customSafeAreaInsets.top
        galleryView.collectionView.contentInset = customSafeAreaInsets
        galleryView.collectionView.dataSource = self
        galleryView.collectionView.delegate = self
        galleryView.collectionView.collectionViewLayout = Self.makeLayout()
        galleryView.collectionView.register(GalleryCell.self, forCellWithReuseIdentifier: "GalleryCell")
        galleryView.collectionView.register(
            GallerySectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: GallerySectionHeaderView.reuseIdentifier
        )
        galleryView.headerView.backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanDismiss(_:)))
        pan.delegate = self
        galleryView.collectionView.addGestureRecognizer(pan)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let offset: CGFloat = 8
        let headerHeight = galleryView.headerView.frame.height
        if galleryView.collectionView.contentInset.top != headerHeight {
            galleryView.collectionView.contentInset.top = headerHeight + offset
            galleryView.collectionView.verticalScrollIndicatorInsets.top = headerHeight + offset
        }
    }
    
    // MARK: - Sections & Data
    enum Section: Int, CaseIterable {
        case horizontal = 0, grid = 1
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int { Section.allCases.count }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .horizontal: return topItems.count
        case .grid:       return gridItems.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        let item: GalleryItem
        let radius: CGFloat
        switch Section(rawValue: indexPath.section)! {
        case .horizontal:
            item = topItems[indexPath.item]
            radius = 8
        case .grid:
            item = gridItems[indexPath.item]
            radius = 2
        }
        cell.configure(with: item.media)
        cell.applyCornerRadius(radius)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { fatalError() }
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: GallerySectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as! GallerySectionHeaderView

        view.label.text = (indexPath.section == 0) ? "Trending" : "Discover"
        return view
    }
    
    // MARK: - Layout
    static func makeLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { section, env in
            let cellSpacing: CGFloat = 2
            if section == 0 {
                // Section 0 : horizontal (3 colonnes visibles)
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = .init(top: 0, leading: cellSpacing * 2, bottom: 0, trailing: cellSpacing * 2)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(200))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 3)
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
                section.boundarySupplementaryItems = [
                    NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .absolute(36)
                        ),
                        elementKind: UICollectionView.elementKindSectionHeader,
                        alignment: .top
                    )
                ]
                return section
            } else {
                let columns: CGFloat = 3
                let cellWidth = (env.container.effectiveContentSize.width - (columns-1)*cellSpacing) / columns
                let cellHeight = cellWidth
                // 5 lignes (max ligne de 0 à 4), certaines cellules verticales
                let groupHeight = cellHeight * 5 + cellSpacing * 4

                let group = NSCollectionLayoutGroup.custom(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(groupHeight)
                    )
                ) { env in
                    var frames: [NSCollectionLayoutGroupCustomItem] = []
                    // 1 : colonne 0, lignes 0-1 (vertical 2x1)
                    frames.append(NSCollectionLayoutGroupCustomItem(
                        frame: CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight * 2 + cellSpacing)))
                    // 2 : colonne 1, ligne 0
                    frames.append(NSCollectionLayoutGroupCustomItem(
                        frame: CGRect(x: cellWidth + cellSpacing, y: 0, width: cellWidth, height: cellHeight)))
                    // 3 : colonne 2, ligne 0
                    frames.append(NSCollectionLayoutGroupCustomItem(
                        frame: CGRect(x: 2 * (cellWidth + cellSpacing), y: 0, width: cellWidth, height: cellHeight)))
                    // 4 : colonne 1, ligne 1
                    frames.append(NSCollectionLayoutGroupCustomItem(
                        frame: CGRect(x: cellWidth + cellSpacing, y: cellHeight + cellSpacing, width: cellWidth, height: cellHeight)))
                    // 5 : colonne 2, ligne 1
                    frames.append(NSCollectionLayoutGroupCustomItem(
                        frame: CGRect(x: 2 * (cellWidth + cellSpacing), y: cellHeight + cellSpacing, width: cellWidth, height: cellHeight)))
                    // 6 : colonnes 0-1, ligne 2 (horizontal 1x2)
                    frames.append(NSCollectionLayoutGroupCustomItem(
                        frame: CGRect(x: 0, y: 2 * (cellHeight + cellSpacing), width: 2 * cellWidth + cellSpacing, height: cellHeight)))
                    // 7 : colonne 2, lignes 2-3 (vertical 2x1)
                    frames.append(NSCollectionLayoutGroupCustomItem(
                        frame: CGRect(x: 2 * (cellWidth + cellSpacing), y: 2 * (cellHeight + cellSpacing), width: cellWidth, height: cellHeight * 2 + cellSpacing)))
                    // 8 : colonne 0, ligne 3
                    frames.append(NSCollectionLayoutGroupCustomItem(
                        frame: CGRect(x: 0, y: 3 * (cellHeight + cellSpacing), width: cellWidth, height: cellHeight)))
                    // 9 : colonne 1, ligne 3
                    frames.append(NSCollectionLayoutGroupCustomItem(
                        frame: CGRect(x: cellWidth + cellSpacing, y: 3 * (cellHeight + cellSpacing), width: cellWidth, height: cellHeight)))
                    // 10 : colonne 0, ligne 4
                    frames.append(NSCollectionLayoutGroupCustomItem(
                        frame: CGRect(x: 0, y: 4 * (cellHeight + cellSpacing), width: cellWidth, height: cellHeight)))
                    // 11 : colonne 1, lignes 4-5 (vertical 2x1)
                    frames.append(NSCollectionLayoutGroupCustomItem(
                        frame: CGRect(x: cellWidth + cellSpacing, y: 4 * (cellHeight + cellSpacing), width: cellWidth * 2 + cellSpacing, height: cellHeight)))
                    // Si tu veux rajouter plus d’items (autre pattern ou vide)

                    return frames
                }
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = cellSpacing
                section.contentInsets = .zero
                section.boundarySupplementaryItems = [
                    NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .absolute(36)
                        ),
                        elementKind: UICollectionView.elementKindSectionHeader,
                        alignment: .top
                    )
                ]
                return section
            }
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
        let location = pan.location(in: galleryView.collectionView)
        if let indexPath = galleryView.collectionView.indexPathForItem(at: location) {
            if indexPath.section == 0 {
                // Si on swipe dans la section 0 (carrousel horizontal) => on ne trigger PAS le dismiss
                return false
            }
        }
        return true
    }
    
    @objc private func handlePanDismiss(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let percent = min(max(translation.x / view.bounds.width, 0), 1)

        switch gesture.state {
        case .began:
            if let feedVC = presentingViewController {
                feedVC.view.layer.cornerRadius = UIConstant.device.cornerRadius
                feedVC.view.layer.masksToBounds = true
            }
            
            // Instancie ou récupère ton transitioningDelegate
            let transition = GallerySlideTransitioningDelegate()
            slideTransitioningDelegate = transition
            transition.interactiveTransition = UIPercentDrivenInteractiveTransition()
            transitioningDelegate = transition
            galleryView.collectionView.isScrollEnabled = false
            modalPresentationStyle = .custom
            dismiss(animated: true, completion: nil)
        case .changed:
            slideTransitioningDelegate?.interactiveTransition?.update(percent)
        case .ended, .cancelled:
            if percent > 0.3 {
                slideTransitioningDelegate?.interactiveTransition?.finish()
            } else {
                slideTransitioningDelegate?.interactiveTransition?.cancel()
            }
            galleryView.collectionView.isScrollEnabled = true
            slideTransitioningDelegate?.interactiveTransition = nil
        default: break
        }
    }
    
    @objc private func handleBackButton() {
        // 1. Ajoute le radius au parent (VC qui t’a présenté)
        if let parentView = presentingViewController?.view {
            parentView.layer.cornerRadius = UIConstant.device.cornerRadius
            parentView.layer.masksToBounds = true
        }

        // 2. (optionnel) clean transition interactive
        if let slideDelegate = slideTransitioningDelegate,
           let interactive = slideDelegate.interactiveTransition {
            interactive.cancel()
            slideDelegate.interactiveTransition = nil
            return
        }

        // 3. dismiss
        dismiss(animated: true, completion: nil)
    }
}

extension GalleryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let discoverHeader = visibleSectionHeaderView(forSection: 0) else { return }
        
        let headerFrameInWindow = discoverHeader.convert(discoverHeader.bounds, to: view)
        let headerViewMaxY = galleryView.headerView.convert(galleryView.headerView.bounds, to: view).maxY
        
        // Range d'interpolation sur 32 points
        let transitionRange: CGFloat = 16
        let offset = headerViewMaxY - headerFrameInWindow.minY
        
        // Calcule l’alpha de façon linéaire
        let progress = min(max(offset / transitionRange, 0), 1)
        galleryView.headerView.blurAlpha = progress
    }
    
    // Helper : retourne le header visible pour une section donnée
    private func visibleSectionHeaderView(forSection section: Int) -> UICollectionReusableView? {
        let visibleHeaders = galleryView.collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader)
        return visibleHeaders.first(where: { view in
            if let indexPath = galleryView.collectionView.indexPath(forSupplementaryView: view), indexPath.section == section {
                return true
            }
            return false
        })
    }
}
