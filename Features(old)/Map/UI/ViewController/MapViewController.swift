//
//  MapViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 01/10/2025.
//

import UIKit
import MapKit

extension MapFeature.UI.ViewController {
    final class MapViewController: UIViewController, MKMapViewDelegate {
        
        // MARK: - Alias
        // Domain
        typealias Annotation = MapFeature.Domain.Model.Annotation

        // UI - ViewModel
        typealias AnnotationListViewModel = MapFeature.UI.ViewModel.AnnotationListViewModel

        // UI - Views
        typealias AnnotationBaseViewConfig = MapFeature.UI.View.AnnotationBaseViewConfig
        typealias AnnotationView = MapFeature.UI.View.AnnotationView
        typealias ClusterView = MapFeature.UI.View.ClusterView
        
        // MARK: - UI
        private let mapView = MKMapView()
        
        // MARK: - ViewModel
        private let viewModel: AnnotationListViewModel
        
        // MARK: - Callbacks
        var onSelectAnnotation: (([Annotation]) -> Void)?
        
        // MARK: - Init
        init(viewModel: AnnotationListViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) { fatalError() }
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupMapView()
            bindViewModel()
            
            Task {
                await viewModel.loadAnnotations()
            }
        }
        
        // MARK: - Setup
        private func setupMapView() {
            mapView.frame = view.bounds
            mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            mapView.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: AnnotationView.identifier)
            mapView.register(ClusterView.self, forAnnotationViewWithReuseIdentifier: ClusterView.identifier)
            
            if #available(iOS 17.0, *) {
                let config = MKStandardMapConfiguration(elevationStyle: .realistic)
                config.showsTraffic = false
                config.pointOfInterestFilter = .excludingAll
                mapView.preferredConfiguration = config
            }
            view.addSubview(mapView)
            
            mapView.delegate = self
        }
        
        private func bindViewModel() {
            viewModel.onAnnotationsUpdated = { [weak self] annotations in
                guard let self else { return }
                self.mapView.addAnnotations(annotations)
            }
        }
        
        // MARK: - Annotation View
        private func makeAnnotationView(for annotation: Annotation, on mapView: MKMapView) -> AnnotationView {
            let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: AnnotationView.identifier,
                for: annotation
            ) as! AnnotationView
            
            view.annotation = annotation
            view.clusteringIdentifier = "post"
            
            view.setConfig(
                AnnotationBaseViewConfig(
                    size: 72,
                    cornerRadius: 16,
                    borderWidth: 2.5,
                    borderColor: .accent,
                    backgroundColor: .black,
                    animateOnAppear: true
                )
            )
            
            view.onTap = { [weak self] post in
                self?.onSelectAnnotation?([post])
            }
            
            return view
        }
        
        // MARK: - Cluster View
        private func makeClusterView(for annotation: MKClusterAnnotation, on mapView: MKMapView) -> ClusterView {
            let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: ClusterView.identifier,
                for: annotation
            ) as! ClusterView
            
            view.annotation = annotation
            
            view.setConfig(
                AnnotationBaseViewConfig(
                    size: 72,
                    cornerRadius: 16,
                    borderWidth: 2.5,
                    borderColor: .accent,
                    backgroundColor: .black,
                    animateOnAppear: true
                )
            )
            
            view.onTap = { [weak self] _ in
                let annotations = annotation.memberAnnotations.compactMap {
                    $0 as? Annotation
                }
                self?.onSelectAnnotation?(annotations)
            }
            return view
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let postAnnotation = annotation as? Annotation {
                return makeAnnotationView(for: postAnnotation, on: mapView)
            }
            
            if let clusterAnnotation = annotation as? MKClusterAnnotation {
                return makeClusterView(for: clusterAnnotation, on: mapView)
            }
            
            return nil
        }
    }
}
