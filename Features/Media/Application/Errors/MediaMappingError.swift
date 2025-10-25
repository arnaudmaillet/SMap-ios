//
//  MediaMappingError.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 16/10/2025.
//

import Foundation

extension MediaNamespace.Application.Errors {
    enum MediaMappingError: Error, LocalizedError {
        case invalidURL(String)
        case missingID
        case unknown

        var errorDescription: String? {
            switch self {
            case .invalidURL(let urlString):
                return "URL invalide pour le média : \(urlString)"
            case .missingID:
                return "ID manquant pour l'entité média"
            case .unknown:
                return "Erreur de mapping inconnue"
            }
        }
    }
}
