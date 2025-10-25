//
//  ComponentID.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 20/10/2025.
//

import Foundation

/// Type-safe identifier linking a Feature Namespace and a specific component (DataSource, Repository, etc.)
public struct ComponentID<Feature, Component>: CustomStringConvertible {
    
    // MARK: - Static accessors

    /// Canonical name, e.g. "PostNamespace.PostRemoteDataSourceImpl"
    public static var name: String {
        "\(Feature.self).\(Component.self)"
    }

    /// Short component name, e.g. "PostRemoteDataSourceImpl"
    public static var shortName: String {
        String(describing: Component.self)
    }

    // MARK: - Instance
    
    /// Stored canonical name, for instance-level use (useful if you want to store one)
    public let value: String = "\(Feature.self).\(Component.self)"
    
    /// Conformance to `CustomStringConvertible`
    public var description: String {
        "[\(Feature.self)] \(Component.self)"
    }
}
