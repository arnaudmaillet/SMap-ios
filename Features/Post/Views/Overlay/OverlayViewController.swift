//
//  OverlayViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 29/04/2025.
//


//import UIKit
//
//final class OverlayViewController: UIViewController {
//
//    private let overlayView = OverlayView()
//    private var bottomVC: OverlayBottomViewController?
//    private var topVC: OverlayTopViewController?
//
//    private var post: Post.Model?
//    private var appliedSafeAreaInsets: UIEdgeInsets?
//    private var isFollowing = false
//    private var hasAppliedConfiguration = false
//
//    override func loadView() {
//        self.view = overlayView
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        applyConfigurationIfNeeded()
//    }
//
//    func configure(with post: Post.Model, safeAreaInsets: UIEdgeInsets) {
//        self.post = post
//        self.appliedSafeAreaInsets = safeAreaInsets
//        applyConfigurationIfNeeded()
//    }
//
//    private func applyConfigurationIfNeeded() {
//        guard !hasAppliedConfiguration,
//              let post,
//              let insets = appliedSafeAreaInsets else { return }
//
//        hasAppliedConfiguration = true
//
//        // ⬇️ Top
//        let topVC = OverlayTopViewController(post: post)
//        overlayView.injectTopViewController(topVC, into: self)
////        topVC.applySafeAreaInsets(insets)
////        topVC.updateFollowState(isFollowing: isFollowing)
////        topVC.view.backgroundColor = .blue.withAlphaComponent(0.5)
////        topVC.onFollowStateChanged = { [weak self] newValue in
////            self?.isFollowing = newValue
////            // ➕ Propager si besoin
////        }
//
//        self.topVC = topVC
//
//        // ⬇️ Bottom
//        let bottomVC = OverlayBottomViewController(post: post)
//        bottomVC.view.backgroundColor = .red.withAlphaComponent(0.5)
//        overlayView.injectBottomViewController(bottomVC, into: self)
//        bottomVC.applySafeAreaInsets(insets)
//
//        self.bottomVC = bottomVC
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            print("🟡 OverlayVC view: \(self.view.frame)")
//            print("🟢 overlayView: \(self.overlayView.frame)")
//            print("🟣 topViewContainer: \(self.overlayView.topViewContainer.frame)")
//            print("🔴 bottomContainerView: \(self.overlayView.bottomContainerView.frame)")
//
//            if let topVC = self.topVC {
//                print("📘 topVC.view.frame: \(topVC.view.frame)")
//            }
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            print("📐 topViewContainer height: \(self.overlayView.topViewContainer.frame.height)")
//            print("📐 bottomContainerView height: \(self.overlayView.bottomContainerView.frame.height)")
//        }
//    }
//}


import UIKit

final class OverlayViewController: UIViewController {

    private let overlayView = OverlayView()
    private var bottomVC: OverlayBottomViewController?
    private var topVC: OverlayTopViewController?

    private var post: Post.Model?
    private var appliedSafeAreaInsets: UIEdgeInsets?
    private var isFollowing = false
    private var hasAppliedConfiguration = false

    override func loadView() {
        self.view = overlayView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyConfigurationIfNeeded()
    }

    func configure(with post: Post.Model, safeAreaInsets: UIEdgeInsets) {
        self.post = post
        self.appliedSafeAreaInsets = safeAreaInsets
        applyConfigurationIfNeeded()
    }

    private func applyConfigurationIfNeeded() {
        guard !hasAppliedConfiguration,
              let post,
              let insets = appliedSafeAreaInsets else { return }

        hasAppliedConfiguration = true

        // ⬇️ Top
        let topVC = OverlayTopViewController(post: post)
        overlayView.injectTopViewController(topVC, into: self)
        topVC.applySafeAreaInsets(insets)
        topVC.updateFollowState(isFollowing: isFollowing)
        topVC.onFollowStateChanged = { [weak self] newValue in
            self?.isFollowing = newValue
            // ➕ Propager si besoin
        }

        self.topVC = topVC

        // ⬇️ Bottom
        let bottomVC = OverlayBottomViewController(post: post)
        overlayView.injectBottomViewController(bottomVC, into: self)
        bottomVC.applySafeAreaInsets(insets)

        self.bottomVC = bottomVC
    }
}
