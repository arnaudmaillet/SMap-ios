//
//  MapViewModel.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 01/10/2025.
//

import Foundation

extension MapFeature.UI.ViewModel {
    
    @MainActor
    final class AnnotationListViewModel {
        typealias Annotation = MapFeature.Domain.Model.Annotation
        typealias DefaultFetchAnnotationsUseCase = MapFeature.Domain.UseCase.DefaultFetchAnnotationsUseCase
        
        private let fetchAnnotationsUseCase: DefaultFetchAnnotationsUseCase
        private(set) var annotations: [Annotation] = [] {
            didSet {
                onAnnotationsUpdated?(annotations)
            }
        }
        
        var onAnnotationsUpdated: (([Annotation]) -> Void)?
        
        // DI (Dependency Injection)
        init(fetchAnnotationsUseCase: DefaultFetchAnnotationsUseCase) {
            self.fetchAnnotationsUseCase = fetchAnnotationsUseCase
        }
        
        func loadAnnotations() async {
            do {
                let result = try await fetchAnnotationsUseCase.execute()
                await MainActor.run {
                    self.annotations = result
                }
            } catch {
                print("❌ Failed to fetch annotations: \(error)")
                self.annotations = []
            }
        }
    }
}

