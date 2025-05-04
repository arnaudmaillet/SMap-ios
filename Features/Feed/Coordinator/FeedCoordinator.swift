//
//  FeedCoordinator.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 27/04/2025.
//

import UIKit
import MapKit

protocol FeedCoordinatorProtocol: AnyObject {
    func presentFeed(for posts: [Post.Model], from annotationView: MKAnnotationView, in mapView: MKMapView, image: UIImage)
}

final class FeedCoordinator: FeedCoordinatorProtocol {

    // MARK: - Properties

    private weak var presentingViewController: (UIViewController & FeedControllerDelegate)?

    // MARK: - Initialization

    init(presentingViewController: UIViewController & FeedControllerDelegate) {
        self.presentingViewController = presentingViewController
    }

    // MARK: - Private Methods

    /// Presents a feed view from an annotationView using an array of posts.
    func presentFeed(for posts: [Post.Model], from annotationView: MKAnnotationView, in mapView: MKMapView, image: UIImage) {
        presentFeedView(for: posts.count == 1 ? .single(posts[0]) : .multiple(posts), from: annotationView, in: mapView, image: image)
    }

    /// Presents the FeedViewController with a custom transition from an annotationView and a given FeedContent.
    private func presentFeedView(for content: FeedContent, from annotationView: MKAnnotationView, in mapView: MKMapView, image: UIImage) {
        guard let animatedView = extractPreviewView(from: annotationView) else { return }
        guard let window = presentingViewController?.view.window else { return }
        let frameInWindow = animatedView.convert(animatedView.bounds, to: window)
        let feedViewController = FeedViewController(feedContent: content, originImage: image)
        
        feedViewController.originFrame = frameInWindow
        feedViewController.modalPresentationStyle = .custom
        feedViewController.delegate = presentingViewController
        feedViewController.mapContainerView = (presentingViewController as? HomeViewController)?.contentView
        
        let selectedPost: Post.Model
        if let cluster = annotationView as? Post.Annotation.ClusterView,
           let best = cluster.selectedPost {
            selectedPost = best
        } else {
            guard let firstPost = content.posts.first else { return }
            selectedPost = firstPost
        }
        
        let transitionDelegate = NavigationTransitionDelegate(
            originView: animatedView,
            originFrame: frameInWindow,
            post: selectedPost
        )
        feedViewController.transitioningDelegate = transitionDelegate
        
        presentingViewController?.present(feedViewController, animated: true)
    }

    /// Extracts the preview UIView from an annotation view (single post or cluster).
    private func extractPreviewView(from annotationView: MKAnnotationView) -> UIView? {
        if let postView = annotationView as? Post.Annotation.View {
            return postView.preview
        } else if let clusterView = annotationView as? Post.Annotation.ClusterView {
            return clusterView.preview
        }
        return nil
    }
}
