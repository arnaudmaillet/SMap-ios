//
//  HomeViewController+AnnotationView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 27/04/2025.
//

import UIKit

extension HomeViewController: AnnotationViewDelegate {
    func annotationView(_ view: Post.Annotation.View, didTapWith post: Post.Model) {
        guard let image = post.mainRenderable?.thumbnailImage else { return }
        showFeed(for: [post], from: view, image: image)
    }
}


extension HomeViewController: ClusterViewDelegate {
    func clusterView(_ view: Post.Annotation.ClusterView, didTapWith posts: [Post.Model], previewImage: UIImage?) {
        guard let image = previewImage else { return }
        showFeed(for: posts, from: view, image: image)
    }
}
