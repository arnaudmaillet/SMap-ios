//
//  Array+Extensions.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 17/05/2025.
//

import Foundation
import CoreLocation

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    /// Déplace le l' élément a l'index x vers l'index y
    mutating func move(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex,
              indices.contains(sourceIndex),
              (0...count).contains(destinationIndex) else { return }

        let element = remove(at: sourceIndex)

        // destinationIndex peut être égal à count (append à la fin)
        insert(element, at: destinationIndex)
    }
    
    /// Déplace le l' élément a l'index correspondant au predicate
    mutating func move(where predicate: (Element) -> Bool, to destinationIndex: Int) {
        guard let sourceIndex = firstIndex(where: predicate) else { return }
        move(from: sourceIndex, to: destinationIndex)
    }
    
    
    func randomSubset(percent: Double) -> [Element] {
        guard percent > 0 && percent < 1 else { return self }
        let count = Int(Double(self.count) * percent)
        return shuffled().prefix(count).map { $0 }
    }
    
    func asyncMap<T>(_ transform: @escaping (Element) async throws -> T) async rethrows -> [T] {
        var results = [T]()
        for element in self {
            try await results.append(transform(element))
        }
        return results
    }
}

extension Array where Element == MapFeature.Domain.Model.Annotation {
    typealias Annotation = MapFeature.Domain.Model.Annotation
    typealias ClusterConstants = MapFeature.Support.Constants.ClusterConstants
    typealias GeoCircle = MapFeature.Domain.Model.GeoCircle
    
    /// Retourne l'annotation avec le meilleur score (aléatoire en cas d’égalité)
    var bestAnnotation: Annotation? {
        guard !isEmpty else { return nil }
        let maxScore = map(\.clusterScore).max() ?? 0
        return filter { $0.clusterScore == maxScore }.randomElement()
    }

    /// Retourne uniquement les posts
    var postAnnotations: [Annotation] {
        filter {
            if case .post = $0.annotationType { return true }
            return false
        }
    }
    
    func enclosingGeoCircle() -> GeoCircle {
        let center = CLLocationCoordinate2D(
            latitude: mapCenterLatitude,
            longitude: mapCenterLongitude
        )

        let centerLoc = CLLocation(latitude: center.latitude, longitude: center.longitude)

        let maxDistance = self.map {
            CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
        }
        .map { $0.distance(from: centerLoc) }
        .max() ?? ClusterConstants.defaultRadius

        return GeoCircle(center: center, radius: maxDistance * ClusterConstants.radiusTolerenceFactor)
    }

    private var mapCenterLatitude: Double {
        map(\.coordinate.latitude).reduce(0, +) / Double(count)
    }

    private var mapCenterLongitude: Double {
        map(\.coordinate.longitude).reduce(0, +) / Double(count)
    }
}
