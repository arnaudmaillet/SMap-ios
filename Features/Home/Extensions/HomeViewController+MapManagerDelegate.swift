//
//  HomeVIewController+AnnotationDelegate.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 27/04/2025.
//

import Foundation

extension HomeViewController: AnnotationViewDelegate {
    func annotationView(_ view: Post.Annotation.View, didTapWith post: Post.Model) {
        if let image = post.mainRenderable?.thumbnailImage {
            showFeed(for: [post], from: view, image: image)
        }
    }
}
