//
//  HomeViewController+MapManager.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 27/04/2025.
//

import Foundation
import MapKit

extension HomeVC: MapProtocol {
    
    func annotationViewDelegate(for view: Post.Annotation.View) -> AnnotationViewDelegate? {
        return self
    }
    
    func clusterViewDelegate(for view: Post.Annotation.ClusterView) -> ClusterViewDelegate? {
        return self
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        lockInteraction()
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        unlockInteraction()
    }
}
