//
//  CGRect.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 01/07/2025.
//

import UIKit

extension CGRect {
    var center: CGPoint { CGPoint(x: midX, y: midY) }
    
    func unscaledFrame(relativeTo window: UIWindow?, scale: CGFloat) -> CGRect {
        guard let window, scale != 1.0 else { return self }
        let center = CGPoint(x: window.bounds.midX, y: window.bounds.midY)
        let correctedOriginX = (origin.x - center.x) / scale + center.x
        let correctedOriginY = (origin.y - center.y) / scale + center.y
        let correctedWidth = size.width / scale
        let correctedHeight = size.height / scale
        return CGRect(x: correctedOriginX, y: correctedOriginY, width: correctedWidth, height: correctedHeight)
    }
    
    func rounded(to decimals: Int) -> CGRect {
        return CGRect(
            x: origin.x.rounded(to: decimals),
            y: origin.y.rounded(to: decimals),
            width: size.width.rounded(to: decimals),
            height: size.height.rounded(to: decimals)
        )
    }
}
