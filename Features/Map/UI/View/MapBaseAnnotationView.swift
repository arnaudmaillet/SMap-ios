//
//  MapBaseAnnotationView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 01/10/2025.
//

import UIKit
import MapKit

extension MapFeature.UI.View {
    
    struct AnnotationBaseViewConfig {
        var size: CGFloat
        var cornerRadius: CGFloat
        var borderWidth: CGFloat
        var borderColor: UIColor
        var backgroundColor: UIColor
        var animateOnAppear: Bool
        
        static let `default` = AnnotationBaseViewConfig(
            size: 72,
            cornerRadius: 16,
            borderWidth: 2,
            borderColor: .accent,
            backgroundColor: .black,
            animateOnAppear: false
        )
    }

    class BaseAnnotationView: MKAnnotationView {
        let imageView = UIImageView()
        
        /// Config appliquée à la vue (toujours initialisée avec `.default`)
        private(set) var config: AnnotationBaseViewConfig = .default
        
        // MARK: - Init
        override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
            super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
            applyConfig(.default)
        }
        required init?(coder: NSCoder) { fatalError() }
        
        
        // MARK: - Apply Config
        func setConfig(_ newConfig: AnnotationBaseViewConfig) {
            self.config = newConfig
            applyConfig(newConfig)
        }
        
        private func applyConfig(_ config: AnnotationBaseViewConfig) {
            frame.size = CGSize(width: config.size, height: config.size)
            backgroundColor = config.backgroundColor
            layer.cornerRadius = config.cornerRadius + config.size.remainderAfterPowerOfTwo
            layer.borderWidth = config.borderWidth
            layer.borderColor = config.borderColor.cgColor
            clipsToBounds = true
            
            if imageView.superview == nil {
                addSubview(imageView)
            }
            if config.animateOnAppear {
                animateAppearance()
            }
            
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.frame = bounds
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            imageView.frame = bounds
        }
        
        func animateAppearance(duration: TimeInterval = 0.3, delay: TimeInterval = 0) {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

            UIView.animate(
                withDuration: duration,
                delay: delay,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.5,
                options: [.curveEaseOut]
            ) {
                self.alpha = 1
                self.transform = .identity
            }
        }
    }
}

