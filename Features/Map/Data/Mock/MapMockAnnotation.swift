//
//  MockMapAnnotationFactory.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 03/10/2025.
//

import UIKit
import CoreLocation

extension MapFeature.Data.Mock {
    struct MapAnnotationMockFactory {
        typealias Constants = MapFeature.Support.Constants.MockConstants
        typealias AnnotationDTO = MapFeature.Data.DTO.AnnotationDTO
        typealias PostAnnotationDTO = MapFeature.Data.DTO.PostAnnotationDTO
        typealias PostDTO = PostNamespace.Data.DTO.PostDTO
        
        static func makeCollection(from posts: [PostDTO]) -> [AnnotationDTO] {
            let baseCoord = Constants.coordinates
            let offsetRange = Constants.annotationOffsetRange

            return posts.map { post in
                // 📍 Coordonnées aléatoires cohérentes autour d’un point fixe
                let coord = CLLocationCoordinate2D(
                    latitude: baseCoord.latitude + Double.random(in: offsetRange),
                    longitude: baseCoord.longitude + Double.random(in: offsetRange)
                )

                // 🧩 Crée un PostAnnotationDTO léger basé sur le même post
                let postAnnotationDTO = PostAnnotationDTO(
                    id: post.id,
                    authorId: post.authorId,
                    score: post.score,
                    thumbnailRef: post.thumbnailRef
                )

                // 🔐 Encode le PostAnnotationDTO dans un payload
                let payloadData = try? JSONEncoder().encode(postAnnotationDTO)

                // 🗺️ Crée le DTO générique de la Map
                return AnnotationDTO(
                    id: post.id,
                    type: .post,
                    latitude: coord.latitude,
                    longitude: coord.longitude,
                    payload: payloadData ?? Data()
                )
            }
        }
    }
}
