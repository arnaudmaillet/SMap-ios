//
//  AnnotationView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 10/04/2025.
//

import Foundation
import MapKit


extension Post.Annotation {
    final class View: AnnotationBaseView {
        
        // MARK: - Properties
        
        static let identifier = "Annotation"
        weak var delegate: AnnotationViewDelegate?
        
        /// Safely casted annotation model.
        private var postAnnotationModel: Post.Annotation.Model? {
            annotation as? Post.Annotation.Model
        }
        
        // MARK: - Overrides
        
        /// Called when the annotation is set. Configures the preview if the post has a renderable.
        override var annotation: MKAnnotation? {
            didSet {
                guard annotation !== oldValue else { return }
                
                if let post = postAnnotationModel?.post,
                   post.mainRenderable != nil {
                    setupPreview(with: post)
                }
            }
        }
        
        /// Handles tap interactions on the annotation view.
        override func handleTap() {
            guard let post = postAnnotationModel?.post else { return }
            delegate?.annotationView(self, didTapWith: post)
        }
    }
}
