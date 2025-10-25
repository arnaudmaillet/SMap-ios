//
//  ProfileViewModel.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 14/10/2025.
//

import Foundation

extension ProfileFeature.UI.ViewModel {

    @MainActor
    final class ProfileViewModel: ObservableObject {
        typealias PostPreview = PostNamespace.Domain.Entities.PostPreview
        typealias FetchPostPreviewsUseCase = PostNamespace.Application.UseCases.FetchPostPreviewsUseCase

        @Published private(set) var previews: [PostPreview] = []
        @Published private(set) var isLoading: Bool = false
        @Published private(set) var error: Error?

        private let fetchPreviewsUseCase: FetchPostPreviewsUseCase

        init(fetchPreviewsUseCase: FetchPostPreviewsUseCase) {
            self.fetchPreviewsUseCase = fetchPreviewsUseCase
        }

        func load(with previews: [PostPreview]) {
            self.error = nil
            self.isLoading = false
            self.previews = previews
        }
    }
}
