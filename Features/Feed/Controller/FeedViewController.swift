//
//  FeedController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 16/04/2025.
//

import UIKit

final class FeedViewController: UIViewController {

    // MARK: - UI Elements

    private let background = UIView()
    private let contentView = UIView()
    private var collectionView: UICollectionView!
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var dismissGestureHandler: FeedDismissGestureHandler!

    public let transitionContainer = UIView()

    var safeTopInset: CGFloat {
        view.safeAreaInsets.top
    }

    // MARK: - State

    private var originalPosition: CGPoint?

    // MARK: - Input Data

    private let feedContent: FeedContent
    var originFrame: CGRect = .zero
    var originImage: UIImage?
    weak var delegate: FeedControllerDelegate?

    // MARK: - Computed Properties

    var posts: [Post.Model] {
        return feedContent.posts
    }

    var currentPostImageView: UIImageView? {
        guard let indexPath = collectionView.indexPathsForVisibleItems.first,
              let cell = collectionView.cellForItem(at: indexPath) as? FeedCell else {
            return nil
        }
        return cell.imageView
    }

    var currentOverlayView: UIView? {
        guard let indexPath = collectionView.indexPathsForVisibleItems.first,
              let cell = collectionView.cellForItem(at: indexPath) else {
            return nil
        }
        return (cell as? FeedCell)?.overlayView
    }

    var feedBackgroundView: UIView {
        background
    }

    func hideFeedContent() {
        collectionView.isHidden = true
    }

    // MARK: - Init

    init(feedContent: FeedContent, originImage: UIImage? = nil) {
        self.feedContent = feedContent
        self.originImage = originImage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateDismissOverlayView()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTransitionContainer()
        setupOverlay()
        setupContentView()
        setupCollectionView()
        setupPanGesture()
    }

    // MARK: - Setup UI

    private func setupOverlay() {
        background.frame = view.bounds
        background.backgroundColor = .black
        background.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        background.alpha = 1
        view.addSubview(background)
    }

    private func setupContentView() {
        contentView.frame = view.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(contentView)
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = view.bounds.size
        layout.minimumLineSpacing = 0

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: "FeedCell")
        contentView.addSubview(collectionView)
    }

    private func setupPanGesture() {
        dismissGestureHandler = FeedDismissGestureHandler(view: contentView, background: background, overlayView: nil)
        dismissGestureHandler.delegate = self
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }

    private func setupTransitionContainer() {
        transitionContainer.frame = view.bounds
        transitionContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        transitionContainer.isUserInteractionEnabled = false
        view.addSubview(transitionContainer)
    }

    func updateDismissOverlayView() {
        dismissGestureHandler.overlayView = currentOverlayView
    }

    // MARK: - Gesture Handling

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        dismissGestureHandler.handlePan(gesture)
    }

    // MARK: - Dismiss Transition (Private API for GestureHandler)

    func dismissToOrigin() {
        guard let config = HeroDismissConfig.basic(from: self) else {
            dismiss(animated: false) { self.delegate?.feedDidDismiss() }
            return
        }
        
        HeroDismissAnimator.animateDismiss(config: config, from: self) {}
    }

    func resetContentViewPosition(to position: CGPoint?) {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.96,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut],
                       animations: {
            self.contentView.transform = .identity
            self.background.alpha = 0.4
            self.currentOverlayView?.alpha = 1
        }, completion: { _ in
            self.contentView.center = position ?? self.contentView.center
            self.contentView.layer.cornerRadius = 0
            self.background.alpha = 1
        })
    }
}
