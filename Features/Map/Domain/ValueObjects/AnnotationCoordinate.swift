//
//  AnnotationCoordinate.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 24/10/2025.
//

import Foundation
import CoreLocation

extension MapNamespace.Domain.ValueObjects {
    struct AnnotationCoordinate: Equatable {
        let latitude: Double
        let longitude: Double

        var clCoordinate: CLLocationCoordinate2D {
            .init(latitude: latitude, longitude: longitude)
        }

        init(_ cl: CLLocationCoordinate2D) {
            self.latitude = cl.latitude
            self.longitude = cl.longitude
        }

        init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }
}
