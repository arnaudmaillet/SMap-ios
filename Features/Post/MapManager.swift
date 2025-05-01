//
//  MapManager.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 11/04/2025.
//

import UIKit
import MapKit

protocol MapManagerDelegate: AnyObject {
    func didSelectPost(_ post: Post.Model)
    func didSelectCluster(_ posts: [Post.Model])
    func annotationViewDelegate(for view: Post.Annotation.View) -> AnnotationViewDelegate?
    func clusterViewDelegate(for view: Post.Annotation.ClusterView) -> ClusterViewDelegate?
}

final class MapManager: NSObject, MKMapViewDelegate {
    
    // MARK: - Properties
    
    private let mapView: MKMapView
    weak var delegate: MapManagerDelegate?
    var selectedAnnotations: [MKAnnotation] { mapView.selectedAnnotations }
    
    // MARK: - Initialization
    
    init(frame: CGRect) {
        self.mapView = MKMapView(frame: frame)
        super.init()

        setupMapView()
    }
    
    // MARK: - Setup
    
    /// Configures the initial map view settings and appearance.
    private func setupMapView() {
        mapView.delegate = self
        mapView.register(Post.Annotation.View.self, forAnnotationViewWithReuseIdentifier: Post.Annotation.View.identifier)
        mapView.register(Post.Annotation.ClusterView.self, forAnnotationViewWithReuseIdentifier: Post.Annotation.ClusterView.identifier)
        mapView.userTrackingMode = .follow
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.showsTraffic = false
        
        if #available(iOS 13.0, *) {
            let config = MKStandardMapConfiguration()
            config.pointOfInterestFilter = .excludingAll
            config.showsTraffic = false
            mapView.preferredConfiguration = config
        }
    }
    
    // MARK: - Map View Access
    
    /// Public access to the internal MKMapView instance
    func provideMapView() -> MKMapView {
        return mapView
    }
    
    /// Attaches the map view to a specified parent view with full-screen constraints.
    func attachMapView(to parentView: UIView) {
        parentView.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: parentView.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
    }
    
    // MARK: - MKMapViewDelegate
       
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
            return annotationView
        }
        
        if annotation is MKClusterAnnotation {
            let identifier = Post.Annotation.ClusterView.identifier
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? Post.Annotation.ClusterView
            clusterView = clusterView ?? Post.Annotation.ClusterView(annotation: annotation, reuseIdentifier: identifier)
            clusterView?.annotation = annotation
            clusterView?.delegate = delegate?.clusterViewDelegate(for: clusterView!)
            return clusterView
        }
        
        return nil
    }
    
    // MARK: - Annotation Management
    
    /// Returns the view associated with the specified annotation.
    func view(for annotation: MKAnnotation) -> MKAnnotationView? {
        return mapView.view(for: annotation)
    }
    
    /// Adds annotations to the map.
    func addAnnotations(_ annotations: [MKAnnotation]) {
        mapView.addAnnotations(annotations)
    }
    
    /// Refreshes annotations on the map.
    func refreshAnnotations(_ annotations: [MKAnnotation]) {
        mapView.removeAnnotations(annotations)
        mapView.addAnnotations(annotations)
    }
    
    /// Removes annotations from the map.
    func removeAnnotations(_ annotations: [MKAnnotation]) {
        mapView.removeAnnotations(annotations)
    }
    
    /// Deselects annotations with optional animation.
    func deselectAnnotations(_ annotations: [MKAnnotation], animated: Bool) {
        annotations.forEach { mapView.deselectAnnotation($0, animated: animated) }
    }
}
