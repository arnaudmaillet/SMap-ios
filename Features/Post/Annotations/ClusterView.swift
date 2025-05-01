//
//  PostClusterAnnotationView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 14/04/2025.
//

import Foundation
import MapKit

extension Post.Annotation {
    final class ClusterView: AnnotationBaseView {
        
        // MARK: - Properties
        
        static let identifier = "Cluster"
        weak var delegate: ClusterViewDelegate?
        private var bestPost: Post.Model?
        
        /// The post with the highest score in the cluster.
        var selectedPost: Post.Model? {
            return bestPost
        }
        
        /// Safely casted cluster annotation.
        private var clusterAnnotation: MKClusterAnnotation? {
            annotation as? MKClusterAnnotation
        }
        
        // MARK: - Overrides
        
        /// Called when the annotation is set. Configures the preview with the best post.
        override var annotation: MKAnnotation? {
            didSet {
                // Skip if annotation didn't actually change
                guard annotation !== oldValue else { return }
                
                guard let cluster = clusterAnnotation else { return }
                
                if let best = cluster.memberAnnotations
                    .compactMap({ $0 as? Post.Annotation.Model })
                    .max(by: { $0.post.score < $1.post.score }) {
                    
                    bestPost = best.post
                    setupPreview(with: best.post)
                }
            }
        }
        
        /// Handles tap interactions on the cluster view.
        override func handleTap() {
            guard let cluster = clusterAnnotation else { return }
            
            let posts = cluster.memberAnnotations.compactMap { ($0 as? Post.Annotation.Model)?.post }
            let previewImage = preview?.imageView.image
            delegate?.clusterView(self, didTapWith: posts, previewImage: previewImage)
        }
    }
}
