//
//  FeedCell.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 19/04/2025.
//


import UIKit

final class FeedCell: UICollectionViewCell {
    
    // MARK: - Subviews
    
    private var _mediaView = MediaContainerView()
    var pendingMediaView: MediaContainerView?
    private let _overlayView = OverlayView()
    
    // MARK: - State
    var scrollCoordinator: ScrollCoordinator?
    var commentsDataSource: CommentsDataSource?
    
    // MARK: - Callbacks
    var onBackButtonTapped: (() -> Void)?
    var onTapInteractionLeft: (() -> Void)?
    var onTapInteractionRight: (() -> Void)?
    var onFollowTapped: (() -> Void)?
    var onRequestFeedScrollActivation: (() -> Void)?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        
        _mediaView.translatesAutoresizingMaskIntoConstraints = false
        _overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(_mediaView)
        contentView.addSubview(_overlayView)
        
        NSLayoutConstraint.activate([
            _mediaView.topAnchor.constraint(equalTo: contentView.topAnchor),
            _mediaView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            _mediaView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            _mediaView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            _overlayView.topAnchor.constraint(equalTo: contentView.topAnchor),
            _overlayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            _overlayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            _overlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        _overlayView.onBackButtonTapped = { [weak self] in self?.onBackButtonTapped?() }
        _overlayView.onTapInteractionLeft = { [weak self] in self?.onTapInteractionLeft?() }
        _overlayView.onTapInteractionRight = { [weak self] in self?.onTapInteractionRight?() }
        _overlayView.onFollowTapped = { [weak self] in self?.onFollowTapped?() }
        _overlayView.onRequestFeedScrollActivation = { [weak self] in self?.onRequestFeedScrollActivation?() }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        _mediaView.prepareForReuse()
        
        commentsDataSource = nil
        scrollCoordinator = nil
    }
    
    // MARK: - Public API
    
    var mediaView: MediaContainerView {
        get { _mediaView }
        set { _mediaView = newValue }
    }
    
    var overlayView: OverlayView { _overlayView }
    
    func configure(
        with post: Post.Model,
        mediaView: MediaContainerView? = nil,
        safeAreaInsets: UIEdgeInsets,
        parentFeedViewController: FeedViewController,
        scrollCoordinator: ScrollCoordinator
    ) {
        self.scrollCoordinator = scrollCoordinator
        // 🔁 1. Remplacer proprement mediaView si on en fournit un
        if let injected = mediaView {
            _mediaView.removeFromSuperview()
            _mediaView = injected
            contentView.addSubview(_mediaView)
            _mediaView.frame = contentView.bounds
            _mediaView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        } else if let media = post.mainRenderable as? MediaContent {
            _mediaView.display(media: media)
            _mediaView.currentMedia = media
        }

        // 🔁 2. Toujours mettre à jour l’overlay, les commentaires, etc.
        commentsDataSource = CommentsDataSource()
        _overlayView.configure(with: post)
        _overlayView.backDropView.collectionView.dataSource = commentsDataSource
        _overlayView.backDropView.collectionView.reloadData()
        _overlayView.isHidden = false
        _overlayView.alpha = 1
        _overlayView.scrollCoordinator = scrollCoordinator
        _overlayView.applySafeAreaInsets(NSDirectionalEdgeInsets(edgeInsets: safeAreaInsets))
    }
    
    func replaceMediaView(with newView: MediaContainerView) {
        print("♻️ Replacing mediaView in FeedCell")
        _mediaView.removeFromSuperview()
        _mediaView = newView
        contentView.addSubview(_mediaView)
        _mediaView.frame = contentView.bounds
        _mediaView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    func display(media: MediaContent) {
        _mediaView.display(media: media)
    }
    
    func updateProgressBar(count: Int, currentIndex: Int) {
        _overlayView.configureProgressBar(count: count, currentIndex: currentIndex)
        _overlayView.updateProgress(to: currentIndex)
    }
}

final class CommentsDataSource: NSObject, UICollectionViewDataSource {
    let comments: [String]

    init(count: Int = 50) {
        // Génère "Commentaire 1" à "Commentaire 50"
        self.comments = (1...count).map { "Commentaire \($0)" }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommentCell", for: indexPath) as! CommentCell
        cell.configure(with: comments[indexPath.item])
        return cell
    }
}
