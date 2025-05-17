import UIKit

final class FeedViewController: UIViewController {

    // MARK: - UI Elements

    private let contentView = UIView()
    var collectionView: UICollectionView!
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var dismissGestureHandler: FeedDismissGestureHandler!
    var cellControllers: [IndexPath: FeedCellController] = [:]

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

    weak var mapContainerView: UIView?
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

    // MARK: - Init

    init(feedContent: FeedContent, originImage: UIImage? = nil) {
        self.feedContent = feedContent
        self.originImage = originImage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTransitionContainer()
        setupContentView()
        setupCollectionView()
        setupPanGesture()
    }

    // MARK: - Setup UI

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

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: "FeedCell")

        contentView.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    private func setupPanGesture() {
        dismissGestureHandler = FeedDismissGestureHandler(
            view: contentView,
            overlayView: nil,
            mapContainerView: mapContainerView
        )
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


    func hideFeedContent() {
        collectionView.isHidden = true
    }

    // MARK: - Gesture Handling

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        dismissGestureHandler.handlePan(gesture)
    }

    // MARK: - Dismiss Transition (Private API for GestureHandler)

    func dismissToOrigin() {
        dismiss(animated: true)
    }

    func resetContentViewPosition(to position: CGPoint?) {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.96,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut],
                       animations: {
            self.contentView.transform = .identity
        }, completion: { _ in
            self.contentView.center = position ?? self.contentView.center
            self.contentView.layer.cornerRadius = 0
        })
    }

    // MARK: - ScrollView Gesture

    func updateCurrentCellCornerRadius(scrollView: UIScrollView) {
        guard let indexPath = collectionView.indexPathsForVisibleItems.first,
              let cell = collectionView.cellForItem(at: indexPath) as? FeedCell else {
            return
        }

        let offsetY = scrollView.contentOffset.y
        let maxOffsetY = scrollView.contentSize.height - scrollView.bounds.height
        let isOnFirstCell = indexPath.item == 0
        let isOnLastCell = indexPath.item == posts.count - 1

        var radius: CGFloat = 0

        if isOnFirstCell && offsetY < 0 {
            radius = min(abs(offsetY) * 0.75, 55)
        } else if isOnLastCell && offsetY > maxOffsetY {
            radius = min((offsetY - maxOffsetY) * 0.75, 55)
        }

        cell.applyCornerRadius(radius)
    }
    
    func currentOverlayView() -> UIView? {
        guard let indexPath = collectionView.indexPathsForVisibleItems.first,
              let cell = collectionView.cellForItem(at: indexPath) as? FeedCell else {
            return nil
        }
        return cell.overlayVC.view
    }
    
    func injectOverlayController(_ vc: OverlayViewController, into containerView: UIView) {
        addChild(vc)
        containerView.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            vc.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])

        vc.didMove(toParent: self)
    }
    
    var isInteractingWithReactionsScroll = false {
        didSet {
            collectionView.isScrollEnabled = !isInteractingWithReactionsScroll
        }
    }
}
