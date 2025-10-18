import UIKit
import MapKit

final class HomeViewController: UIViewController {
    
    struct HomeActionButtonSection {
        let actions: [HomeActionButtonModel]
        var selectedIndex: Int
    }

    // MARK: - Properties

    private let viewModel: HomeViewModel
    let mapManager: MapManager
    private weak var feedContainerCoordinator: FeedCoordinatorDelegate?
    var lastSelectedAnnotation: MKAnnotation?
    private(set) var posts: [Post.Model]
    
    private var isInteractionAllowed = true
    private var isMapMoving = false
    private var allowInteractionTimer: Timer?
    private(set) var contentView = UIView()
    private let headerView = HomeHeaderView()
    private var collectionHeightConstraint: NSLayoutConstraint!
    
    // ---- Remplace l’ancien actionButtons par ce tableau de sections :
    private var buttonSections: [HomeActionButtonSection] = [
        .init(actions: [
            .init(iconName: "bookmark"),
            .init(iconName: "globe.americas", title: "World"),
            .init(iconName: "mappin.circle", title: "France"),
            .init(iconName: "mappin.circle", title: "Paris"),
            .init(iconName: "fork.knife", title: "KFC"),
            .init(iconName: "storefront", title: "Fnac"),
            .init(iconName: "person", title: "Squeezie"),
            .init(iconName: "mappin.circle", title: "China"),
            .init(iconName: "mappin.circle", title: "USA")
        ], selectedIndex: 2),
//        .init(actions: [
//            .init(iconName: "bell.badge"),
//            .init(title: "Channel 1"),
//            .init(title: "Channel 2"),
//            .init(title: "Channel 3"),
//            .init(title: "Channel 4"),
//            .init(title: "Channel 5"),
//            .init(title: "Channel 6"),
//        ], selectedIndex: 1),
        .init(actions: [
            .init(iconName: "magnifyingglass"),
            .init(iconName: "plus.circle"),
            .init(iconName: "person.crop.rectangle.stack", title: "For you"),
            .init(iconName: "flame", title: "Trending"),
            .init(iconName: "person.2.fill", title: "Following"),
            .init(iconName: "building.2", title: "Services"),
            .init(iconName: "building.2", title: "Services"),
            .init(iconName: "building.2", title: "Services"),
        ], selectedIndex: 2),
    ]
    
    // Nouvelle collection verticale
    private lazy var verticalCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(HomeActionButtonRowCell.self, forCellWithReuseIdentifier: HomeActionButtonRowCell.reuseIdentifier)
        return cv
    }()

    // MARK: - Initialization

    init(viewModel: HomeViewModel, mapManager: MapManager) {
        self.viewModel = viewModel
        self.mapManager = mapManager
        self.posts = []
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        verticalCollectionView.layoutIfNeeded()
        collectionHeightConstraint.constant = verticalCollectionView.collectionViewLayout.collectionViewContentSize.height
    }

    func setFeedContainerCoordinator(_ coordinator: FeedCoordinatorDelegate) {
        self.feedContainerCoordinator = coordinator
    }

    // MARK: - Setup
    private func setupMap() {
        mapManager.attachMapView(to: contentView)
    }

    @MainActor
    private func loadPosts() {
        posts = []
        _ = viewModel.loadMockPosts(
                offline: true,
                videoOnly: true,
                onPostReady: { [weak self] post in
                    guard let self else { return }
                    let annotation = Post.Annotation.Model(post: post)
                    self.mapManager.addAnnotations([annotation])
                    self.posts.append(post)
                }
            )
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        setupMap()
        mapManager.delegate = self
        loadPosts()
        
        view.addSubview(verticalCollectionView)
        collectionHeightConstraint = verticalCollectionView.heightAnchor.constraint(equalToConstant: 1)
        collectionHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            verticalCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            verticalCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            verticalCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    // MARK: - Annotation Handling

    func refreshLastSelectedAnnotation() {
        guard let annotation = lastSelectedAnnotation else { return }
        mapManager.refreshAnnotations([annotation])
    }

    func setLastSelectedAnnotation(_ annotation: MKAnnotation?) {
        lastSelectedAnnotation = annotation
    }
    
    func showLastSelectedAnnotation() {
        guard let annotation = lastSelectedAnnotation else { return }
        if let view = mapManager.view(for: annotation) {
            view.isHidden = false
        }
    }
    
    // MARK: - Public API

    func showFeed(for posts: [Post.Model], selectedPost: Post.Model, from annotationView: MKAnnotationView) {
        guard isInteractionAllowed else { return }
        setLastSelectedAnnotation(annotationView.annotation)
        mapManager.setInteractionEnabled(false)
        feedContainerCoordinator?.presentFeedFromMap(for: posts, selectedPost: selectedPost, from: annotationView, in: mapManager.provideMapView())
    }
    
    func setMapInteractionEnabled(_ isEnabled: Bool) {
        mapManager.setInteractionEnabled(isEnabled)
    }
    
    func lockInteraction() {
        allowInteractionTimer?.invalidate()
        isInteractionAllowed = false
        isMapMoving = true
    }

    func unlockInteraction(after delay: TimeInterval = 0) {
        allowInteractionTimer?.invalidate()
        allowInteractionTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.isInteractionAllowed = true
            self?.isMapMoving = false
        }
    }
    
    func currentAnnotationFrameInWindow() -> CGRect? {
        guard let annotation = lastSelectedAnnotation,
              let annotationView = mapManager.view(for: annotation) else {
            return nil
        }
        return annotationView.convert(annotationView.bounds, to: view.window)
    }
    
    func waitUntilAnnotationIsRendered(_ annotation: MKAnnotation, completion: @escaping () -> Void) {
        mapManager.waitForAnnotationRender(annotation, completion: completion)
    }
    
    func launchFeedDirectly(with posts: [Post.Model]) {
        print("🚀 launchFeedDirectly called with \(posts.count) posts")
        DispatchQueue.main.async {
            let dummyAnnotationView = MKAnnotationView(frame: CGRect(x: 0, y: 0, width: 72, height: 72))
            dummyAnnotationView.image = UIImage(systemName: "photo")
            self.setLastSelectedAnnotation(dummyAnnotationView.annotation)
            self.mapManager.setInteractionEnabled(false)
            self.feedContainerCoordinator?.presentFeedFromMap(
                for: posts,
                selectedPost: posts[0],
                from: dummyAnnotationView,
                in: self.mapManager.provideMapView()
            )
        }
    }
}