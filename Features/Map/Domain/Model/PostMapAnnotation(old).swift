//
//  PostMapAnnotation.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 03/10/2025.
//

import UIKit
import CoreLocation

extension MapFeature.Domain.Model {
    struct PostThumbnailData {
        let thumbnail: UIImage?
        let score: Int
        let authorId: UUID
    }
    
    final class PostAnnotation: NSObject, Annotation {
        typealias AnnotationType = MapFeature.Domain.Model.AnnotationType
        typealias Post = PostNamespace.Domain.Entities.Post
        
        let id: UUID
        let coordinate: CLLocationCoordinate2D
        let clusterScore: Int
        let image: UIImage?
        let authorId: UUID
        
        var annotationType: AnnotationType

        init(id: UUID, coordinate: CLLocationCoordinate2D, postData: PostThumbnailData) {
            self.id = id
            self.coordinate = coordinate
            self.clusterScore = postData.score
            self.image = postData.thumbnail
            self.authorId = postData.authorId
            self.annotationType = .post(postData)
        }
        
        func asPost() -> Post {
            guard case .post(let data) = annotationType else {
                fatalError("Invalid annotation type for PostAnnotation")
            }

            return Post(
                id: id,
                authorId: data.authorId,
                caption: nil,
                media: [],
                score: data.score,
                createdAt: Date(),
                isFull: false
            )
        }
    }
}
