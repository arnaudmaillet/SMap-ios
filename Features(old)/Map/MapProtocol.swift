//
//  MapProtocol.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 28/04/2025.
//

import Foundation
import MapKit

protocol MapProtocol: AnyObject {
    func annotationViewDelegate(for view: Post.Annotation.View) -> AnnotationViewDelegate?
    func clusterViewDelegate(for view: Post.Annotation.ClusterView) -> ClusterViewDelegate?
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool)
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
}
