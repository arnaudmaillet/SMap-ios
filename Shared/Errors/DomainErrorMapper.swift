//
//  DomainErrorMapper.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 19/10/2025.
//

import Foundation

/// Un mapper générique pour transformer les erreurs techniques (Infrastructure)
/// en erreurs métier (Domaine)
public struct DomainErrorMapper<Feature> {
    
    /// Transforme automatiquement une erreur infrastructurelle en DomainError.
    /// - Parameter error: Une erreur venant du Repository ou DataSource.
    /// - Returns: Une erreur spécifique au domaine.
    public static func map(_ error: Error) -> Error {
        switch error {
        case let repoError as RepositoryError<Feature>:
            return mapRepositoryError(repoError)
            
        case let dataError as DataSourceError<Feature>:
            return mapDataSourceError(dataError)
            
        default:
            return makeUnknownError(from: error)
        }
    }
    
    // MARK: - Private Mappings
    
    private static func mapRepositoryError(_ error: RepositoryError<Feature>) -> Error {
        switch error {
        case .notFound:
            return makeDomainError(type: "notFound")
        case .cacheMiss:
            return makeDomainError(type: "unavailable")
        case .dataSource(_, let underlying):
            if let dsError = underlying as? DataSourceError<Feature> {
                return mapDataSourceError(dsError)
            }
            return makeDomainError(type: "unavailable")
        default:
            return makeUnknownError(from: error)
        }
    }
    
    private static func mapDataSourceError(_ error: DataSourceError<Feature>) -> Error {
        switch error {
        case .network:
            return makeDomainError(type: "unavailable")
        case .mapping:
            return makeDomainError(type: "unavailable")
        case .notFound:
            return makeDomainError(type: "notFound")
        default:
            return makeUnknownError(from: error)
        }
    }
    
    // MARK: - Fallback
    
    private static func makeDomainError(type: String) -> Error {
        // Ce fallback est neutre — il sera spécialisé plus bas.
        return NSError(domain: "DomainError.\(Feature.self)", code: -1, userInfo: [
            NSLocalizedDescriptionKey: type
        ])
    }
    
    private static func makeUnknownError(from error: Error) -> Error {
        NSError(domain: "DomainError.\(Feature.self)", code: -999, userInfo: [
            NSLocalizedDescriptionKey: "Erreur inconnue : \(error.localizedDescription)"
        ])
    }
}


extension DomainErrorMapper where Feature == PostNamespace {
    static func makeDomainError(type: String) -> Error {
        switch type {
        case "notFound":
            return PostNamespace.Domain.Errors.PostDomainError.notFound
        case "unavailable":
            return PostNamespace.Domain.Errors.PostDomainError.unavailable
        default:
            return PostNamespace.Domain.Errors.PostDomainError.unknown(
                NSError(domain: "PostNamespace", code: -999)
            )
        }
    }
}
