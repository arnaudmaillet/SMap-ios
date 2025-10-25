//
//  AnnotationMapper.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 24/10/2025.
//

import Foundation
import CoreGraphics

extension MapNamespace.Application.Mappers {
    struct PostAnnotationMapper {

        typealias DTO = MapNamespace.Application.DTOs.PostAnnotationDTO
        typealias Domain = MapNamespace.Domain.Entities.PostAnnotation

        // MARK: - DTO → Domain
        static func toDomain(_ dto: DTO) -> Domain? {
            guard let url = URL(string: dto.mediaURL) else {
                return nil
            }

            let size: CGSize? = {
                if let width = dto.mediaWidth, let height = dto.mediaHeight {
                    return CGSize(width: width, height: height)
                }
                return nil
            }()

            return Domain(
                id: dto.id,
                mediaURL: url,
                mediaType: dto.mediaType,
                mediaSize: size,
                caption: dto.caption,
                authorUsername: dto.authorUsername,
                authorAvatarURL: dto.authorAvatarURL.flatMap(URL.init(string:)),
                hasAudio: dto.hasAudio ?? false,
                blurHash: dto.blurHash,
                isNSFW: dto.isNSFW ?? false
            )
        }

        // MARK: - Domain → DTO
        static func toDTO(_ domain: Domain) -> DTO {
            DTO(
                id: domain.id,
                mediaURL: domain.mediaURL.absoluteString,
                mediaType: domain.mediaType,
                mediaWidth: Int(domain.mediaSize?.width ?? 0),
                mediaHeight: Int(domain.mediaSize?.height ?? 0),
                caption: domain.caption,
                authorUsername: domain.authorUsername,
                authorAvatarURL: domain.authorAvatarURL?.absoluteString,
                hasAudio: domain.hasAudio,
                blurHash: domain.blurHash,
                isNSFW: domain.isNSFW
            )
        }
    }
}
