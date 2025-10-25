//
//  ScrollCoordinator.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 12/06/2025.
//

import UIKit

final class ScrollCoordinator {
    // MARK: - Types
    
    private class WeakScrollView {
        weak var scrollView: UIScrollView?
        init(_ scrollView: UIScrollView) { self.scrollView = scrollView }
    }

    // MARK: - Properties

    private var scrollViews: [WeakScrollView] = []
    private(set) weak var activeScrollView: UIScrollView?

    // MARK: - Public

    /// Ajoute une scrollView à la coordination
    func addScrollView(_ scrollView: UIScrollView) {
        // Evite les doublons
        if !scrollViews.contains(where: { $0.scrollView === scrollView }) {
            scrollViews.append(WeakScrollView(scrollView))
        }
    }

    /// Active la scrollView donnée (désactive toutes les autres)
    func activate(_ scrollView: UIScrollView?) {
            for weakScroll in scrollViews {
                if let sv = weakScroll.scrollView {
                    sv.isScrollEnabled = (sv === scrollView)
                    if sv === scrollView {
                        activeScrollView = sv
                    }
                }
            }

        // Nettoyage (supprime les scrollViews nil)
        scrollViews = scrollViews.filter { $0.scrollView != nil }
    }

    /// Désactive tout
    func deactivateAll() {
        for weakScroll in scrollViews {
            weakScroll.scrollView?.isScrollEnabled = false
        }
        activeScrollView = nil
    }

    /// True si la scrollView passée est active
    func isActive(_ scrollView: UIScrollView?) -> Bool {
        return scrollView != nil && scrollView === activeScrollView
    }
}
