//
//  PostFeature.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 18/10/2025.
//

extension PostNamespace {
    protocol PostFeature {
        typealias GetPostUseCase = PostNamespace.Application.UseCases.GetPostUseCase
        
        var getPostUseCase: GetPostUseCase { get }
    }
}
