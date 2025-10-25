//
//  AnnotationTye.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 24/10/2025.
//


import Foundation

extension MapNamespace.Domain.ValueObjects {
    enum AnnotationType: String, Codable, Equatable {
        case post
        case user
        // case poi
        // case event
        // case sponsored
    }
}
