//
//  ImageCache.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 14/04/2025.
//

import UIKit

final class ImageCache {
    static let shared: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
        return cache
    }()
}

extension UIImageView {
    func loadImage(
        from url: URL,
        placeholder: UIImage? = UIImage(named: "placeholder"),
        completion: ((UIImage?) -> Void)? = nil
    ) {
        let key = url.absoluteString as NSString

        if let cached = ImageCache.shared.object(forKey: key) {
            self.image = cached
            completion?(cached)
            return
        }

        self.image = placeholder

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error loading image: \(error.localizedDescription)")
            }
            guard let data,
                  let image = UIImage(data: data),
                  (response as? HTTPURLResponse)?.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion?(nil)
                }
                return
            }

            let cost = data.count
            ImageCache.shared.setObject(image, forKey: key, cost: cost)

            DispatchQueue.main.async {
                self.image = image
                completion?(image)
            }
        }.resume()
    }
}
