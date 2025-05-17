//
//  MapManager.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 11/04/2025.
//

import UIKit
import MapKit

final class MapManager: NSObject {
    
    // MARK: - Properties
    
    private let mapView: MKMapView
    weak var delegate: MapProtocol?
    private var annotationRenderCallbacks: [String: () -> Void] = [:]
    var selectedAnnotations: [MKAnnotation] { mapView.selectedAnnotations }
    var onAnnotationViewRendered: ((MKAnnotation) -> Void)?
    
    // MARK: - Initialization
    
    init(frame: CGRect) {
        mapView = MKMapView(frame: frame)
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

        if #available(iOS 17.0, *) {
            let config = MKStandardMapConfiguration(elevationStyle: .realistic)
            config.showsTraffic = false
            config.pointOfInterestFilter = .excludingAll
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
        
        mapView.layer.cornerRadius = 52.25
        mapView.layer.masksToBounds = true 
    }
    
    // MARK: - Interaction Control

    /// Enables or disables user interaction on the map.
    func setInteractionEnabled(_ isEnabled: Bool) {
        mapView.isScrollEnabled = isEnabled
        mapView.isZoomEnabled = isEnabled
        mapView.isRotateEnabled = isEnabled
        mapView.isPitchEnabled = isEnabled
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
    
    // Appelé depuis HomeViewController ou autre contrôleur pour attendre l’apparition
    func waitForAnnotationRender(_ annotation: MKAnnotation, completion: @escaping () -> Void) {
        let key = annotation.annotationIdentifier
        annotationRenderCallbacks[key] = completion
    }

    // À appeler dans mapView(_:viewFor:)
    func handleViewRendering(for annotation: MKAnnotation) {
        let key = annotation.annotationIdentifier
        if let callback = annotationRenderCallbacks.removeValue(forKey: key) {
            DispatchQueue.main.async {
                callback()
            }
        }
    }
}
