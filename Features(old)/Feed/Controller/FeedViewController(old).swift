import UIKit

final class FeedViewController: UIViewController, CollectionViewContainer {

    // MARK: - UI Elements
    var collectionView: UICollectionView
    var cellControllers: [IndexPath: FeedCellController] = [:]
    let scrollCoordinator = ScrollCoordinator()
    
    var lockedPostIndex: Int = 0
    var lastCurrentIndex: Int?
    private var playingIndexPath: IndexPath?
    
    var onCurrentPostChange: ((Post.Model?) -> Void)?
    let viewModel: FeedViewModel
    
    var safeTopInset: CGFloat {
        view.safeAreaInsets.top
    }
    
    private var lastPlayingIndex: IndexPath?
    
    weak var gestureDelegate: FeedContainerGestureHandler?
    weak var exitDelegate: HeroDimissableStackScreen?

    // MARK: - Computed Properties
    
    private var visibleCellControllers: [(IndexPath, FeedCellController)] {
        let sorted = collectionView.indexPathsForVisibleItems.sorted { $0.item < $1.item }
        return sorted.compactMap { indexPath in
            guard let controller = cellControllers[indexPath], controller.cell != nil else { return nil }
            return (indexPath, controller)
        }
    }
    
    var currentVisibleController: FeedCellController? {
        visibleCellControllers.first?.1
    }
    
    var currentPost: Post.Model? {
        guard let indexPath = collectionView.indexPathsForVisibleItems.first else { return nil }
        return viewModel.post(at: indexPath.item)
    }
    
    var currentMedia: MediaContent? {
        return currentVisibleController?.currentMedia
    }
    
    // MARK: - Init

    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
        let layout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        let insets = view.safeAreaInsets
        let directionalInsets = NSDirectionalEdgeInsets(
            top: insets.top,
            leading: insets.left,
            bottom: insets.bottom,
            trailing: insets.right
        )

        for indexPath in collectionView.indexPathsForVisibleItems {
            if let controller = cellControllers[indexPath] {
                controller.applySafeAreaInsets(directionalInsets)
            }
        }
    }

    // MARK: - Setup UI

    private func setupCollectionView() {  
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = view.bounds.size
        layout.minimumLineSpacing = 0

        collectionView = FeedCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        collectionView.bounces = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: "FeedCell")

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func cellController(at indexPath: IndexPath) -> FeedCellController? {
        return cellControllers[indexPath]
    }
    
    func ensureCellController(
        for indexPath: IndexPath,
        post: Post.Model,
        forceIfNeeded: Bool = false
    ) -> FeedCellController? {
        if let existing = cellControllers[indexPath] {
            return existing
        }

        guard let feedCell = collectionView.cellForItem(at: indexPath) as? FeedCell else {
            if forceIfNeeded {
                collectionView.layoutIfNeeded()
                collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
                collectionView.layoutIfNeeded()
                return ensureCellController(for: indexPath, post: post, forceIfNeeded: false)
            }
            return nil
        }

        let controller = FeedCellController(
            cell: feedCell,
            with: post,
            safeAreaInsets: view.safeAreaInsets,
            parentFeedViewController: self,
            scrollCoordinator: scrollCoordinator
        )
        cellControllers[indexPath] = controller
        return controller
    }
    
    func resetLayout(keepViewHidden: Bool = false) {
        if !keepViewHidden {
            view.alpha = 1
            view.isHidden = false
        }
        view.transform = .identity
        view.center = view.center
    }
    
    // MARK: - Dismiss Transition (Private API for GestureHandler)

    func restoreIdleUIState(to position: CGPoint?) {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.96,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut],
                       animations: {
            self.view.transform = .identity
        }, completion: { _ in
            self.view.center = position ?? self.view.center
            self.view.layer.cornerRadius = 0
        })
    }
    
    // MARK: - ScrollView Gesture
    
    func currentOverlayView() -> UIView? {
        return currentVisibleController?.cell?.overlayView
    }
    
    func handleInteractiveTransition(gesture: UIPanGestureRecognizer, interactive: UIPercentDrivenInteractiveTransition) {
        let translation = gesture.translation(in: view)
        let percent = min(max(-translation.x / view.bounds.width, 0), 1)
        
        switch gesture.state {
        case .changed:
            interactive.update(percent)
        case .ended, .cancelled:
            if percent > 0.25 {
                interactive.finish()
            } else {
                interactive.cancel()
            }
        default:
            break
        }
    }
    
    
    func updateCurrentPlayingVideo() {
        guard let window = collectionView.window else { return }
        let collectionRectInWindow = collectionView.convert(collectionView.bounds, to: window)

        var bestController: FeedCellController?
        var bestIndexPath: IndexPath?
        var maxRatio: CGFloat = 0

        for (indexPath, controller) in visibleCellControllers {
            guard
                let cell = controller.cell,
                let media = controller.currentMedia,
                media.isVideo,
                let cellRectInWindow = cell.superview?.convert(cell.frame, to: window)
            else { continue }

            let intersection = cellRectInWindow.intersection(collectionRectInWindow)
            let visibleArea = intersection.width * intersection.height
            let totalArea = cellRectInWindow.width * cellRectInWindow.height
            let ratio = (totalArea > 0) ? (visibleArea / totalArea) : 0

            if ratio > maxRatio {
                maxRatio = ratio
                bestController = controller
                bestIndexPath = indexPath
            }
        }

        guard let majorController = bestController,
              let majorIndexPath = bestIndexPath,
              maxRatio >= 0.5,
              let media = majorController.currentMedia,
              media.isVideo
        else {
            if let playing = playingIndexPath,
               let previousController = cellControllers[playing] {
                previousController.pausePlayer()
                playingIndexPath = nil
            }
            return
        }
        if playingIndexPath != majorIndexPath {
            if let previous = playingIndexPath,
               let previousController = cellControllers[previous] {
                previousController.pausePlayer()
            }
            majorController.displayCurrentMedia()
            playingIndexPath = majorIndexPath
        }

        // Pause tous les autres visibles sauf major
        for (indexPath, controller) in visibleCellControllers where indexPath != majorIndexPath {
            controller.pausePlayer()
        }
    }

    
//    func removeLockedPosts(except mediaIdToKeep: UUID? = nil) {
//        guard lockedPostIndex < posts.count else {
//            print("❌ [FeedVC] lockedPostIndex out of bounds")
//            return
//        }
//        
//        print("🧹 [FeedVC] Suppression de tous les posts jusqu’au locked index : \(lockedPostIndex)")
//        
//        // 1. Supprime les cellControllers associés
//        for i in 0...lockedPostIndex {
//            let indexPath = IndexPath(item: i, section: 0)
//            if let controller = cellControllers[indexPath] {
//                if controller.currentMedia?.id != mediaIdToKeep {
//                    controller.releasePlayerIfNeeded()
//                }
//                controller.cell = nil
//                cellControllers.removeValue(forKey: indexPath)
//            }
//        }
//        
//        // 2. Supprime les posts
//        posts.removeFirst(lockedPostIndex + 1)
//        
//        // 3. Supprime les cellules de la collectionView
//        let indexPathsToDelete = (0...lockedPostIndex).map { IndexPath(item: $0, section: 0) }
//        collectionView.performBatchUpdates {
//            collectionView.deleteItems(at: indexPathsToDelete)
//        }
//        
//        // 4. Décale les cellControllers restants
//        let oldControllers = cellControllers
//        cellControllers.removeAll()
//        for (oldIndexPath, controller) in oldControllers {
//            let newIndex = oldIndexPath.item - (lockedPostIndex + 1)
//            guard newIndex >= 0 else { continue }
//            let newIndexPath = IndexPath(item: newIndex, section: 0)
//            cellControllers[newIndexPath] = controller
//        }
//        
//        // 5. Reset locked index
//        lockedPostIndex = 0
//        
//        // 6. Revenir à l'index 0 (post non verrouillé suivant)
//        collectionView.setContentOffset(.zero, animated: false)
//    }
    
    func saveCurrentPlayingIndex(_ index: IndexPath?) {
        lastPlayingIndex = index
    }
    
    func resumeLastPlayingVideo() {
        guard let indexPath = lastPlayingIndex,
              let controller = cellControllers[indexPath]
        else { return }
        
        controller.displayCurrentMedia()
        playingIndexPath = indexPath
    }
    
    func triggerDismiss() {
        exitDelegate?.dismiss()
    }
}

extension FeedViewController: HeroViewControllable {
    
    func heroTransitionData() -> Any? {
        guard let data = currentVisibleController?.post else {
            print("⚠️ [AnimDest] Pas de data disponible pour la destination")
            return nil
        }
        return data
    }
    
    func heroAnimatedView(at indexPath: IndexPath) -> UIView? {
        guard let view = currentVisibleController?.cell?.mediaView else {
            print("⚠️ [AnimDest] Pas de mediaView trouvée, fallback sur FeedViewController.view")
            return self.view
        }
        return view
    }
    
    func heroContainerView(at indexPath: IndexPath) -> UIView? {
        collectionView.layoutIfNeeded()
        return collectionView.cellForItem(at: indexPath)
    }
    
    func heroDestinationData(at indexPath: IndexPath) -> Any? {
        guard let data = currentVisibleController?.post else {
            print("⚠️ [AnimDest] Pas de data disponible pour la destination")
            return nil
        }
        return data
    }
    
    func didFinishHeroTransition(
        at indexPath: IndexPath,
        with data: Any,
        animatedView: UIView,
        phase: HeroTransitionPhase
    ) {
        guard let post = data as? Post.Model else { return }

        viewModel.replacePost(at: indexPath.item, with: post)

        if let controller = cellControllers[indexPath] {
            controller.updateMedia(with: post)
        }

        collectionView.layoutIfNeeded()

        if let cell = collectionView.cellForItem(at: indexPath) as? FeedCell {
            cell.replaceMediaView(with: animatedView as! MediaContainerView)
            cell.contentView.bringSubviewToFront(cell.overlayView)
        } else {
            let controller = ensureCellController(for: indexPath, post: post, forceIfNeeded: false)
            controller?.cell?.pendingMediaView = animatedView as? MediaContainerView
        }

        updateCurrentPlayingVideo()
        collectionView.isScrollEnabled = true
    }
}

protocol FeedContainerGestureHandler: AnyObject {
    func prepareForHeroDismiss()
}

final class FeedCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard
            let panGR = gestureRecognizer as? UIPanGestureRecognizer,
            let feedVC = self.delegate as? FeedViewController
        else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }

        let velocity = panGR.velocity(in: self)
        let offsetY = contentOffset.y
        let pageHeight = bounds.height
        let currentIndex = Int(round(offsetY / pageHeight))
        let isSnapped = abs(offsetY - CGFloat(currentIndex) * pageHeight) < 1

        if velocity.y > 0,
           currentIndex <= feedVC.lockedPostIndex,
           isSnapped {
            feedVC.gestureDelegate?.prepareForHeroDismiss()
            return false
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
