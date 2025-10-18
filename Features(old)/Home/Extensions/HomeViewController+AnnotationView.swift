//
//  HomeViewController+AnnotationView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 27/04/2025.
//

import UIKit

extension HomeVC: AnnotationViewDelegate {
    func annotationView(_ view: Post.Annotation.View, didTapWith post: Post.Model) {
        showFeed(for: [post], selectedPost: post, from: view)
    }
}


extension HomeVC: ClusterViewDelegate {
    func clusterView(_ view: Post.Annotation.ClusterView, didTapWith posts: [Post.Model], selectedPost: Post.Model) {
        showFeed(for: posts, selectedPost: selectedPost, from: view)
    }
}
