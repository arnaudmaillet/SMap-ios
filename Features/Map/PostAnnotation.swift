//
//  PostAnnotation.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 14/04/2025.
//

import MapKit

final class PostAnnotation: NSObject, MKAnnotation {
    let post: Post
    var coordinate: CLLocationCoordinate2D { post.coordinate }

    init(post: Post) {
        self.post = post
    }
}
