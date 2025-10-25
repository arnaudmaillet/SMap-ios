//
//  AccountStatusMapper.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 20/10/2025.
//


extension UserNamespace.Domain.ValueObjects.AccountStatus {
    
    static func fromDTO(_ dtoStatus: UserNamespace.Application.DTOs.AccountStatusDTO?) -> Self {
        guard let dtoStatus else { return .active }
        switch dtoStatus {
        case .active: return .active
        case .suspended: return .suspended
        case .deactivated: return .deactivated
        case .banned: return .banned
        }
    }

    func toDTO() -> UserNamespace.Application.DTOs.AccountStatusDTO {
        switch self {
        case .active: return .active
        case .suspended: return .suspended
        case .deactivated: return .deactivated
        case .banned: return .banned
        }
    }
}
