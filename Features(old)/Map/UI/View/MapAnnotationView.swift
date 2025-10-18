//
//  MapAnnotationView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 01/10/2025.
//

import UIKit
import MapKit

extension MapFeature.UI.View {
    final class AnnotationView: BaseAnnotationView {
        typealias Annotation = MapFeature.Domain.Model.Annotation
        
        static let identifier = "AnnotationView"

        var onTap: ((Annotation) -> Void)?

        override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
            super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
            isUserInteractionEnabled = true
            setupTapGesture()
        }

        required init?(coder: NSCoder) { fatalError() }

        override var annotation: MKAnnotation? {
            didSet {
                guard let annotation = annotation as? Annotation else { return }
                configure(with: annotation)
            }
        }

        private func configure(with annotation: Annotation) {
            if let image = annotation.image {
                imageView.image = image
            } else {
                imageView.image = UIImage(named: "placeholder")
            }
        }

        private func setupTapGesture() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            addGestureRecognizer(tap)
        }

        @objc private func handleTap() {
            guard let annotation = annotation as? Annotation else { return }
            onTap?(annotation)
        }
    }
}


