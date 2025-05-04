//
//  ClusterView.swift
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
        
        private(set) var clusterModel: MKClusterAnnotation?
        private(set) var bestPost: Post.Model?
        private var lastBestPostId: UUID?
        
        /// The post with the highest score in the cluster.
        var selectedPost: Post.Model? {
            return bestPost
        }
        
        // MARK: - Init
        
        override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
            super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
            configure(with: annotation)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Overrides
        
        override var annotation: MKAnnotation? {
            didSet {
                guard annotation !== oldValue else { return }
                configure(with: annotation)
            }
        }
        
        override func handleTap() {
            guard let cluster = clusterModel else { return }
            
            
            let posts = cluster.memberAnnotations
                .compactMap { ($0 as? Post.Annotation.Model)?.post }
            
            let previewImage = preview?.imageView.image
            
            delegate?.clusterView(self, didTapWith: posts, previewImage: previewImage)
        }
        
        // MARK: - Private
        
        private func configure(with annotation: MKAnnotation?) {
            clusterModel = annotation as? MKClusterAnnotation
            
            guard let clusterModel else {
                bestPost = nil
                lastBestPostId = nil
                return
            }
            
            if let best = clusterModel.memberAnnotations
                .compactMap({ $0 as? Post.Annotation.Model })
                .max(by: { $0.post.score < $1.post.score }) {
                
                bestPost = best.post
                
                if best.post.id != lastBestPostId {
                    lastBestPostId = best.post.id
                    
                    if best.post.mainRenderable != nil {
                        setupPreview(with: best.post)
                    }
                }
                
            } else {
                bestPost = nil
                lastBestPostId = nil
            }
        }
    }
}
