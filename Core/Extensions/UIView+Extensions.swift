//
//  UIView+Extensions.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 16/04/2025.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: [UIView]) {
        views.forEach { addSubview($0) }
    }
    
    /// Finds the nearest parent view controller in the responder chain.
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let currentResponder = responder {
            if let viewController = currentResponder as? UIViewController {
                return viewController
            }
            responder = currentResponder.next
        }
        return nil
    }
    
    func renderAsImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        return renderer.image { context in
            self.layer.render(in: context.cgContext)
        }
    }
    
    func applyRoundedMask(_ radius: CGFloat) {
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        layer.mask = maskLayer
        layer.masksToBounds = true
    }
    
    func debugSubviews(_ maxDepth: Int? = nil,
                           _ showConstraints: Bool = false,
                           currentDepth: Int = 0) {
            if currentDepth == 0 {
                print("\n" + String(repeating: "=", count: 50) + "\n")
                print("🌳 DEBUG VIEW HIERARCHY (Max Depth: \(maxDepth.map(String.init) ?? "Unlimited"))")
            }

            if let maxDepth = maxDepth, currentDepth > maxDepth {
                return
            }

            let indent = String(repeating: "  ", count: currentDepth)
            let viewType = String(describing: self.classForCoder)
            let tagInfo = self.tag != 0 ? " [Tag: \(self.tag)]" : ""

            print("\(indent)├─ \(viewType)\(tagInfo)")

            // Infos sur la vue courante
            let localFrame = self.frame.rounded(to: 1)
            let frameInScreen = self.convert(self.bounds, to: nil).rounded(to: 1)

            print("\(indent)  │- frame (local): \(localFrame)")
            print("\(indent)  │- frame (screen): \(frameInScreen)")

            // Affiche les frames du parent uniquement pour la racine (depth = 0)
            if currentDepth == 0, let parent = self.superview {
                let parentFrame = parent.frame.rounded(to: 1)
                let parentFrameInScreen = parent.convert(parent.bounds, to: nil).rounded(to: 1)

                print("\(indent)  │- parent frame (local): \(parentFrame)")
                print("\(indent)  │- parent frame (screen): \(parentFrameInScreen)")
            }

            if showConstraints {
                printConstraints(indent: indent + "  │")
            }

            // Recurse sur les subviews
            subviews.forEach {
                $0.debugSubviews(maxDepth, showConstraints, currentDepth: currentDepth + 1)
            }

            if currentDepth == 0 {
                print("\n" + String(repeating: "=", count: 50) + "\n")
            }
        }
    
    func ajustFrameInWindowForScale(_ scale: CGFloat) -> CGRect {
        guard let window = debugUnwrap(self.window) else {
            return .zero
        }

        let rawFrame = self.convert(self.bounds, to: window)
        
        guard scale != 1.0 else { return rawFrame }

        let center = CGPoint(x: window.bounds.midX, y: window.bounds.midY)
        let correctedOriginX = (rawFrame.origin.x - center.x) / scale + center.x
        let correctedOriginY = (rawFrame.origin.y - center.y) / scale + center.y
        let correctedWidth = rawFrame.size.width / scale
        let correctedHeight = rawFrame.size.height / scale

        return CGRect(x: correctedOriginX, y: correctedOriginY, width: correctedWidth, height: correctedHeight)
    }

    private func printAdditionalInfo(indent: String) {
        if let label = self as? UILabel {
            print("\(indent)Text: \"\(label.text ?? "nil")\"")
        } else if let button = self as? UIButton {
            print("\(indent)Title: \"\(button.titleLabel?.text ?? "nil")\"")
        } else if let imageView = self as? UIImageView {
            print("\(indent)Image: \(imageView.image != nil ? "✅" : "nil")")
        }

        print("\(indent)Frame: \(self.frame)")

        if self.alpha != 1.0 {
            print("\(indent)Alpha: \(self.alpha) 🟠")
        }
        if self.isHidden {
            print("\(indent)isHidden: true 🟠")
        }
        if !self.isUserInteractionEnabled {
            print("\(indent)isUserInteractionEnabled: false 🟡")
        }
    }

    private func printConstraints(indent: String) {
        guard !self.constraints.isEmpty else { return }
        print("\(indent)Constraints:")
        self.constraints.forEach { constraint in
            print("\(indent)- \(constraint.description.replacingOccurrences(of: "\n", with: ""))")
        }
    }
}
