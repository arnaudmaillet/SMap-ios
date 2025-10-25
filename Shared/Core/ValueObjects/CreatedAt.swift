//
//  CreatedAt.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import Foundation

/// Représente la date de création d’un post dans le domaine.
/// Garantit la cohérence temporelle et offre des helpers métiers (ex: temps écoulé).
struct CreatedAt: Equatable, Comparable {
    // MARK: - Properties
    let value: Date
    
    // MARK: - Init
    init(_ value: Date = Date()) {
        self.value = value
    }
    
    // MARK: - Comparable
    static func < (lhs: CreatedAt, rhs: CreatedAt) -> Bool {
        lhs.value < rhs.value
    }
    
    // MARK: - Helpers Métier
    
    /// Retourne le nombre de secondes écoulées depuis la création
    var timeIntervalSinceCreation: TimeInterval {
        Date().timeIntervalSince(value)
    }
    
    /// Retourne un texte lisible du type "2h", "3j", "5min"
    var timeAgoDisplay: String {
        let interval = Date().timeIntervalSince(value)
        let minute = 60.0
        let hour = 3600.0
        let day = 86400.0
        
        switch interval {
        case 0..<minute:
            return "à l’instant"
        case minute..<hour:
            let m = Int(interval / minute)
            return "\(m) min"
        case hour..<day:
            let h = Int(interval / hour)
            return "\(h) h"
        default:
            let d = Int(interval / day)
            return "\(d) j"
        }
    }
    
    /// Retourne `true` si la date est dans le futur (incohérence)
    var isFuture: Bool {
        value > Date()
    }
    
    /// Retourne `true` si la date est vieille de plus de X jours
    func isOlderThan(days: Int) -> Bool {
        guard let limit = Calendar.current.date(byAdding: .day, value: -days, to: Date()) else { return false }
        return value < limit
    }
}
