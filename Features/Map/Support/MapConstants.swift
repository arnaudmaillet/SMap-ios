//
//  MapConstants.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 04/10/2025.
//

import Foundation
import CoreLocation

import UIKit

extension MapFeature.Support {
    struct Constants {
        enum MockConstants {
            static let annotationCount = 20
            static let annotationOffsetRange = -0.02...0.02
            static let coordinates = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
        }
        
        enum ClusterConstants {
            static let defaultRadius: Double = 500
            static let radiusTolerenceFactor: Double = 1.2
        }
    }
}
