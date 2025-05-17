//
//  MapDelegate.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 28/04/2025.
//

import Foundation
import MapKit

extension MapManager: MKMapViewDelegate {
    
    /// Returns a custom PostAnnotationView for posts and PostClusterAnnotationView for clusters
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        if annotation is Post.Annotation.Model {
            let identifier = Post.Annotation.View.identifier
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? Post.Annotation.View
            annotationView = annotationView ?? Post.Annotation.View(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.annotation = annotation
            annotationView?.clusteringIdentifier = "post"
            annotationView?.delegate = delegate?.annotationViewDelegate(for: annotationView!)

            //Notifie que l'annotation a été rendue
            handleViewRendering(for: annotation)

            return annotationView
        }

        if annotation is MKClusterAnnotation {
            let identifier = Post.Annotation.ClusterView.identifier
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? Post.Annotation.ClusterView
            clusterView = clusterView ?? Post.Annotation.ClusterView(annotation: annotation, reuseIdentifier: identifier)
            clusterView?.annotation = annotation
            clusterView?.delegate = delegate?.clusterViewDelegate(for: clusterView!)

            handleViewRendering(for: annotation)

            return clusterView
        }

        return nil
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        delegate?.mapView(mapView, regionWillChangeAnimated: animated)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        delegate?.mapView(mapView, regionDidChangeAnimated: animated)
    }
}

extension MKAnnotation {
    /// Un identifiant stable basé sur la mémoire ou une propriété de l’objet
    var annotationIdentifier: String {
        if let annotation = self as? Post.Annotation.Model {
            return annotation.post.id.uuidString // suppose que chaque Post a un identifiant unique
        }
        return String(ObjectIdentifier(self).hashValue)
    }
}
