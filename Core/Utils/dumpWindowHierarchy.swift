//
//  dumpWindowHierarchy.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 01/07/2025.
//

import UIKit

func dumpWindowHierarchy() {
    guard let window = UIApplication.shared.windows.first else { print("no window"); return }
    print("\n----- UIWindow hierarchy -----")
    for (i, v) in window.subviews.enumerated() {
        print("window sub[\(i)]: \(type(of: v)) |", v, "hidden:", v.isHidden, "alpha:", v.alpha, "frame:", v.frame)
        for (j, sv) in v.subviews.enumerated() {
            print("   -> sub[\(j)]: \(type(of: sv)) |", sv, "hidden:", sv.isHidden, "alpha:", sv.alpha, "frame:", sv.frame)
        }
    }
    print("-----------------------------\n")
}

func logView(_ view: UIView, label: String) {
    print("[\(label)] isHidden: \(view.isHidden), alpha: \(view.alpha), frame: \(view.frame), bg: \(String(describing: view.backgroundColor))")
    print("Subviews (\(view.subviews.count)):")
    for (i, sub) in view.subviews.enumerated() {
        print("   [\(i)] \(type(of: sub)), isHidden: \(sub.isHidden), alpha: \(sub.alpha), frame: \(sub.frame), bg: \(String(describing: sub.backgroundColor))")
    }
}


func debugPrintViewControllerHierarchy(from vc: UIViewController? = UIApplication.shared.windows.first?.rootViewController, level: Int = 0) {
    guard let vc = vc else { return }
    let prefix = String(repeating: "    ", count: level)
    print("\(prefix)\(type(of: vc)): \(vc) [isHidden: \(vc.view.isHidden), alpha: \(vc.view.alpha), frame: \(vc.view.frame)]")
    
    // Si UINavigationController, dump la stack
    if let nav = vc as? UINavigationController {
        for (i, child) in nav.viewControllers.enumerated() {
            print("\(prefix)    [NavStack \(i)] ->")
            debugPrintViewControllerHierarchy(from: child, level: level + 2)
        }
    }
    // Si UITabBarController, dump les tabs
    if let tab = vc as? UITabBarController, let vcs = tab.viewControllers {
        for (i, child) in vcs.enumerated() {
            print("\(prefix)    [Tab \(i)] ->")
            debugPrintViewControllerHierarchy(from: child, level: level + 2)
        }
    }
    // Dump les enfants (children)
    for (i, child) in vc.children.enumerated() {
        print("\(prefix)    [Child \(i)] ->")
        debugPrintViewControllerHierarchy(from: child, level: level + 2)
    }
    // Dump le modally presented
    if let presented = vc.presentedViewController {
        print("\(prefix)    [Presented] ->")
        debugPrintViewControllerHierarchy(from: presented, level: level + 2)
    }
}

func printSubviewsRecursively(_ view: UIView, depth: Int = 0) {
    print(String(repeating: "  ", count: depth), "- \(type(of: view)), hidden: \(view.isHidden), alpha: \(view.alpha), frame: \(view.frame), bg: \(String(describing: view.backgroundColor))")
    for sub in view.subviews {
        printSubviewsRecursively(sub, depth: depth + 1)
    }
}
