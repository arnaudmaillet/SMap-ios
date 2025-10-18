//
//  GeoCircle.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 06/10/2025.
//

import CoreLocation

extension MapFeature.Domain.Model {
    struct GeoCircle {
        let center: CLLocationCoordinate2D
        let radius: Double
    }
}
