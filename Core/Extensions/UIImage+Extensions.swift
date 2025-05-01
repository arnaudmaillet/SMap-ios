//
//  UIImage+Extensions.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 18/04/2025.
//

import UIKit

extension UIImage {
    func croppedToAspectRatio(size targetSize: CGSize) -> UIImage? {
        let targetRatio = targetSize.width / targetSize.height
        let imageRatio = size.width / size.height
        
        var cropRect = CGRect(origin: .zero, size: size)

        if imageRatio > targetRatio {
            // Trop large → crop sur les côtés
            let newWidth = size.height * targetRatio
            cropRect.origin.x = (size.width - newWidth) / 2
            cropRect.size.width = newWidth
        } else {
            // Trop haut → crop en haut/bas
            let newHeight = size.width / targetRatio
            cropRect.origin.y = (size.height - newHeight) / 2
            cropRect.size.height = newHeight
        }

        // Adapter pour le scale (@2x, @3x)
        let scaledRect = CGRect(
            x: cropRect.origin.x * scale,
            y: cropRect.origin.y * scale,
            width: cropRect.size.width * scale,
            height: cropRect.size.height * scale
        )

        guard let cgImage = cgImage?.cropping(to: scaledRect) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
}
