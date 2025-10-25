//
//  TransitionImageHelper.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 18/04/2025.
//

import Foundation
import MapKit

enum TransitionImageHelper {
    static func getTransitionImage(from annotationView: MKAnnotationView) -> UIImage? {
        if let postView = annotationView as? Post.Annotation.View {
            return postView.preview?.imageView.image
        }

        if let clusterView = annotationView as? Post.Annotation.ClusterView {
            return clusterView.preview?.imageView.image
        }

        return nil
    }
}
