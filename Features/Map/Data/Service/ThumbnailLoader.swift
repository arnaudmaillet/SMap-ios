//
//  ThumbnailLoader.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 03/10/2025.
//

import UIKit

enum ThumbnailLoader {
    static func loadImage(from ref: ThumbnailReference?) async -> UIImage? {
        guard let ref = ref else { return nil }

        switch ref {
        case .asset(let name):
            return UIImage(named: name)
        case .remote(let url):
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                return UIImage(data: data)
            } catch {
                print("❌ Failed to load image from URL: \(url)")
                return nil
            }
        }
    }
}
