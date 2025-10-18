//
//  FeedFlow.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 01/10/2025.
//

import UIKit

extension FeedFeature.Flow {
    final class FeedFlow {
        typealias PostAnnotation = MapFeature.Domain.Model.PostAnnotation
        typealias Annotation = MapFeature.Domain.Model.Annotation
        
        typealias FeedContainer = FeedFeature.Container.FeedContainer
        typealias FeedViewModel = FeedFeature.UI.ViewModel.FeedViewModel
        typealias FeedViewController = FeedFeature.UI.ViewController.FeedViewController
        
        // MARK: - Properties
        private weak var navigationController: UINavigationController?
        private let feedContainer: FeedContainer
        
        // MARK: - Init
        init(navigationController: UINavigationController, feedContainer: FeedContainer) {
            self.navigationController = navigationController
            self.feedContainer = feedContainer
        }
        
        // MARK: - Start
        func start(from annotation: PostAnnotation, in annotations: [Annotation]) {
            Task {
                let viewModel = try await feedContainer.makeFeedViewModelFromAnnotation(annotation, in: annotations)
                let viewController = await FeedViewController(viewModel: viewModel)
                await navigationController?.pushViewController(viewController, animated: true)
            }
        }
        
        @MainActor
        func makeFeedViewController(from annotation: PostAnnotation, in annotations: [Annotation]) async throws -> FeedViewController {
            let viewModel = try await feedContainer.makeFeedViewModelFromAnnotation(annotation, in: annotations)
            return FeedViewController(viewModel: viewModel)
        }
    }
}
