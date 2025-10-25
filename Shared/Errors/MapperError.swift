//
//  SharedMappingError.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 19/10/2025.
//

import Foundation


public enum MapperError<Feature>: Error, CustomStringConvertible {
    case invalidValue(field: String, value: Any?)
    case missingRequiredField(field: String)
    case typeMismatch(field: String, expected: String, actual: String?)
    case custom(message: String)
    
    public var description: String {
        switch self {
        case let .invalidValue(field, value):
            return "[MapperError<\(Feature.self)>] Invalid value for '\(field)': \(String(describing: value))"
        case let .missingRequiredField(field):
            return "[MapperError<\(Feature.self)>] Missing required field: '\(field)'"
        case let .typeMismatch(field, expected, actual):
            return "[MapperError<\(Feature.self)>] Type mismatch in '\(field)': expected \(expected), got \(actual ?? "nil")"
        case let .custom(message):
            return "[MapperError<\(Feature.self)>] \(message)"
        }
    }
}
