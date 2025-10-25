//
//  MediaDimensions.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import Foundation

extension MediaNamespace.Domain.ValueObjects {
    struct MediaDimensions: Equatable {
        let width: Int
        let height: Int
        
        var aspectRatio: CGFloat {
            guard height != 0 else { return 1.0 }
            return CGFloat(width) / CGFloat(height)
        }
    }
}
