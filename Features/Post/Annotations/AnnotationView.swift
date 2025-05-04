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
        
        private(set) var model: Post.Annotation.Model?
        
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
            guard let post = model?.post else { return }
            delegate?.annotationView(self, didTapWith: post)
        }
        
        // MARK: - Private
        
        private func configure(with annotation: MKAnnotation?) {
            model = annotation as? Post.Annotation.Model
            
            if let post = model?.post,
               post.mainRenderable != nil {
                setupPreview(with: post)
            }
        }
    }
}
