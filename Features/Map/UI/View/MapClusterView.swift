//
//  MapClusterView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 01/10/2025.
//

import UIKit
import MapKit

extension MapFeature.UI.View {
    final class ClusterView: BaseAnnotationView {
        typealias Annotation = MapFeature.Domain.Model.Annotation
        
        static let identifier = "ClusterView"

        var onTap: ((Annotation) -> Void)?

        override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
            super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
            isUserInteractionEnabled = true
            setupTapGesture()
        }

        required init?(coder: NSCoder) { fatalError() }

        override var annotation: MKAnnotation? {
            didSet {
                guard let cluster = annotation as? MKClusterAnnotation else { return }
                configure(with: cluster)
            }
        }

        private func configure(with cluster: MKClusterAnnotation) {
            let members = cluster.memberAnnotations.compactMap { $0 as? Annotation }
            guard !members.isEmpty else {
                imageView.image = UIImage(named: "placeholder")
                return
            }

            // 1. Sélectionner les meilleurs selon clusterScore
            let maxScore = members.map { $0.clusterScore }.max() ?? 0
            let bestCandidates = members.filter { $0.clusterScore == maxScore }

            // 2. Si plusieurs avec même score, choisir aléatoirement
            let best = bestCandidates.randomElement()!

            imageView.image = best.image ?? UIImage(named: "placeholder")
        }

        private func setupTapGesture() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            addGestureRecognizer(tap)
        }

        @objc private func handleTap() {
            guard
                let cluster = annotation as? MKClusterAnnotation,
                let members = cluster.memberAnnotations as? [Annotation],
                !members.isEmpty
            else { return }

            let maxScore = members.map { $0.clusterScore }.max() ?? 0
            let bestCandidates = members.filter { $0.clusterScore == maxScore }
            if let best = bestCandidates.randomElement() {
                onTap?(best)
            }
        }
    }
}
