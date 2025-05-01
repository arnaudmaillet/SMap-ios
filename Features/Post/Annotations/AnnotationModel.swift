//
//  Model.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 26/04/2025.
//

import Foundation
import MapKit

extension Post.Annotation {
    final class Model: NSObject, MKAnnotation {
        
        // MARK: - Properties
        
        let post: Post.Model
        let coordinate: CLLocationCoordinate2D
        
        
        // MARK: - Initialization
        
        init(post: Post.Model) {
            self.post = post
            self.coordinate = post.coordinate.clLocationCoordinate
        }
    }
}
