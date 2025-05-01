//
//  AnnotationDelegate.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 27/04/2025.
//

import UIKit

protocol AnnotationViewDelegate: AnyObject {
    func annotationView(_ view: Post.Annotation.View, didTapWith post: Post.Model)
}

protocol ClusterViewDelegate: AnyObject {
    func clusterView(_ view: Post.Annotation.ClusterView, didTapWith posts: [Post.Model], previewImage: UIImage?)
}
