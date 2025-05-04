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
    
    private func averageBrightness(verticalFraction: Int = 1, verticalIndex: Int = 0,
                                       horizontalFraction: Int = 1, horizontalIndex: Int = 0) -> CGFloat? {
            guard let inputImage = CIImage(image: self) else { return nil }

            // Sécurité : éviter les découpages invalides
            guard verticalFraction > 0, horizontalFraction > 0,
                  verticalIndex >= 0, verticalIndex < verticalFraction,
                  horizontalIndex >= 0, horizontalIndex < horizontalFraction else {
                print("⚠️ UIImage.averageBrightness: Indices de fraction hors limites")
                return nil
            }

            let fullExtent = inputImage.extent
            let regionWidth = fullExtent.width / CGFloat(horizontalFraction)
            let regionHeight = fullExtent.height / CGFloat(verticalFraction)

            let extent = CGRect(
                x: fullExtent.origin.x + regionWidth * CGFloat(horizontalIndex),
                y: fullExtent.origin.y + regionHeight * CGFloat(verticalIndex),
                width: regionWidth,
                height: regionHeight
            )

            let context = CIContext(options: [.workingColorSpace: kCFNull!])
            let filter = CIFilter(name: "CIAreaAverage", parameters: [
                kCIInputImageKey: inputImage,
                kCIInputExtentKey: CIVector(cgRect: extent)
            ])!

            guard let outputImage = filter.outputImage else { return nil }

            var bitmap = [UInt8](repeating: 0, count: 4)
            context.render(outputImage,
                           toBitmap: &bitmap,
                           rowBytes: 4,
                           bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                           format: .RGBA8,
                           colorSpace: nil)

            let r = CGFloat(bitmap[0]) / 255
            let g = CGFloat(bitmap[1]) / 255
            let b = CGFloat(bitmap[2]) / 255

            return 0.299 * r + 0.587 * g + 0.114 * b
        }

        func isDark(threshold: CGFloat = 0.7,
                    verticalFraction: Int = 1, verticalIndex: Int = 0,
                    horizontalFraction: Int = 1, horizontalIndex: Int = 0) -> Bool {
            guard let brightness = self.averageBrightness(
                verticalFraction: verticalFraction, verticalIndex: verticalIndex,
                horizontalFraction: horizontalFraction, horizontalIndex: horizontalIndex
            ) else {
                return false
            }
            return brightness < threshold
        }
}
