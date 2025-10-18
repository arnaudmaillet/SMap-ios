//
//  MapAnnotation.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 04/10/2025.
//

import UIKit
import MapKit

// MARK: - Annotation Protocol

extension MapFeature.Domain.Model {
    enum AnnotationType {
        case post(PostThumbnailData)
        case user(UserThumbnailData)
        case poi(POIData)
        case generic
    }
    
    protocol Annotation: MKAnnotation {
        var id: UUID { get }
        var coordinate: CLLocationCoordinate2D { get }
        var annotationType: AnnotationType { get }
        var clusterScore: Int { get }
        var image: UIImage? { get }
    }
}
