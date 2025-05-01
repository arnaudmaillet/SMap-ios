//
//  HomeViewController+FeedDelegate.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 18/04/2025.
//

import UIKit

extension HomeViewController: FeedViewControllerDelegate {
    func feedViewShouldHideAnnotation() {
        guard let selected = mapManager.mapView.selectedAnnotations.first else { return }
        mapManager.mapView.deselectAnnotation(selected, animated: false)
        if let view = mapManager.mapView.view(for: selected) {
            view.isHidden = true
        }
    }

    func feedDidDismiss() {
        guard let annotation = lastSelectedAnnotation else { return }
        if let view = mapManager.mapView.view(for: annotation) {
            view.isHidden = false
            view.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)

            UIView.animate(withDuration: 0.4,
                           delay: 0,
                           usingSpringWithDamping: 0.96,
                           initialSpringVelocity: 0.2,
                           options: [.curveEaseOut],
                           animations: {
                view.transform = .identity
            })

            if let postView = view as? PostAnnotationView, let border = postView.borderLayer {
                animateBorder(border)
            } else if let clusterView = view as? PostClusterAnnotationView, let border = clusterView.borderLayer {
                animateBorder(border)
            }
        }
        lastSelectedAnnotation = nil
    }

    private func animateBorder(_ borderLayer: CALayer) {
        let anim = CABasicAnimation(keyPath: "borderWidth")
        anim.fromValue = 0
        anim.toValue = 3
        anim.duration = 0.2
        anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        borderLayer.add(anim, forKey: "borderWidth")
        borderLayer.borderWidth = 3
    }
}
