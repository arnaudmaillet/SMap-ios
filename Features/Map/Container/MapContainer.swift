//
//  MapContainer.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 03/10/2025.
//

extension MapFeature.Container {
    final class MapContainer {
        // MARK: - Typealiases
        typealias AnnotationRepository = MapFeature.Data.Repository.AnnotationRepository
        typealias LocalAnnotationRepository = MapFeature.Data.Repository.LocalAnnotationRepository
        typealias RemoteAnnotationRepository = MapFeature.Data.Repository.RemoteAnnotationRepository
        
        typealias AnnotationListViewModel = MapFeature.UI.ViewModel.AnnotationListViewModel
        typealias DefaultFetchAnnotationsUseCase = MapFeature.Domain.UseCase.DefaultFetchAnnotationsUseCase

        // MARK: - Properties
        private let env: AppEnvironment
        private let repository: AnnotationRepository

        // MARK: - Init
        init(env: AppEnvironment) {
            self.env = env

            switch env {
            case .local:
                self.repository = LocalAnnotationRepository()
            case .dev, .prod:
                let apiClient = DefaultAPIClient(env: env)
                self.repository = RemoteAnnotationRepository(apiClient: apiClient)
            }
        }

        // MARK: - Factory
        @MainActor func makeMapViewModel() -> AnnotationListViewModel {
            let useCase = DefaultFetchAnnotationsUseCase(repository: repository)
            return AnnotationListViewModel(fetchAnnotationsUseCase: useCase)
        }
    }
}

