//
//  IdentifiableComponent.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 19/10/2025.
//

import Foundation

/// Every component (DataSource, Repository, UseCase, etc.) declares which Feature it belongs to.
/// This lets us generate its `ComponentID` automatically.

public protocol FeatureNamespace {}

public protocol IdentifiableComponent {
    associatedtype Feature: FeatureNamespace
    static var id: String { get }
}

public extension IdentifiableComponent {
    /// Default computed id using `ComponentID<Feature, Self>`
    static var id: String {
        ComponentID<Feature, Self>.name
    }
}
