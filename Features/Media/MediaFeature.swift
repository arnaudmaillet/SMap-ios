//
//  MediaFeature.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import Foundation

extension MediaFeature.DI {
    final class MediaFeature {
        typealias LoadUseCase = MediaFeature.Application.UseCases.LoadMediaUseCase
        typealias PreloadUseCase = MediaFeature.Application.UseCases.PreloadMediaUseCase
        typealias SourceResolverImpl = MediaFeature.Infrastructure.Services.MediaSourceResolverImpl
        
        let loadUseCase: LoadUseCase
        let preloadUseCase: PreloadUseCase
        let sourceResolver: SourceResolverImpl
        
        init(assembler: MediaAssembler) {
            self.loadUseCase = assembler.makeLoadUseCase()
            self.preloadUseCase = assembler.makePreloadUseCase()
            self.sourceResolver = assembler.makeSourceResolver()
            assembler.startCleanupIfNeeded()
        }
    }
}
