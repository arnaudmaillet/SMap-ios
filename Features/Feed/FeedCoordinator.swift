//
//  FeedPresentationManager.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 23/04/2025.
//

import UIKit
import MapKit

final class ... {
    weak var presentingViewController: UIViewController?

    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }

    func presentFeed(for posts: [Post.Model], from annotationView: MKAnnotationView, in mapView: MKMapView, image: UIImage) {
        let content: FeedContent = posts.singleElement.map { .single($0) } ?? .multiple(posts)
        presentFeed(for: content, from: annotationView, in: mapView, image: image)
    }

    private func presentFeed(for content: FeedContent, from annotationView: MKAnnotationView, in mapView: MKMapView, image: UIImage) {
        guard let animatedView = self.extractPreviewView(from: annotationView) else { return }
        
        let frameInWindow = animatedView.convert(animatedView.bounds, to: presentingViewController?.view)
        let feedVC = FeedViewController(feedContent: content, originImage: image)
        feedVC.originFrame = frameInWindow
        feedVC.modalPresentationStyle = .custom
        feedVC.delegate = presentingViewController as? FeedViewControllerDelegate

        let selectedPost: Post.Model
        if let cluster = annotationView as? Post.Annotation.ClusterView,
           let best = cluster.selectedPost {
            selectedPost = best
        } else {
            guard let firstPost = content.posts.first else {
                return
            }
            selectedPost = firstPost
        }
        
        let transitionDelegate = NavigationTransitionDelegate(
            originView: animatedView,
            originFrame: frameInWindow,
            post: selectedPost
        )
        feedVC.transitioningDelegate = transitionDelegate

        presentingViewController?.present(feedVC, animated: true)
    }

    private func extractPreviewView(from annotationView: MKAnnotationView) -> UIView? {
        if let postView = annotationView as? Post.Annotation.View {
            return postView.preview
        } else if let clusterView = annotationView as? Post.Annotation.ClusterView {
            return clusterView.preview
        }
        return nil
    }
}
