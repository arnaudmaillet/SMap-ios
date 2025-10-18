//
//  ProfileFlow.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 01/10/2025.
//

import UIKit

extension ProfileFeature.Flow {
    final class ProfileFlow {
        typealias ProfileViewController = ProfileFeature.UI.ViewController.ProfileViewController
        typealias ProfileContainer = ProfileFeature.Container.ProfileContainer
        
        typealias PostAnnotation = MapFeature.Domain.Model.PostAnnotation
        typealias Annotation = MapFeature.Domain.Model.Annotation
        
        
        // MARK: - Properties
        private weak var navigationController: UINavigationController?
        private let profileContainer: ProfileContainer
        
        // MARK: - Init
        init(navigationController: UINavigationController, profileContainer: ProfileContainer) {
            self.navigationController = navigationController
            self.profileContainer = profileContainer
        }
        
        // MARK: - Start
        func start(from annotation: PostAnnotation, in annotations: [Annotation]) {
            Task {
                let viewModel = try await profileContainer.makeProfileViewModelFromAnnotation(annotation, in: annotations)
                let viewController = await ProfileViewController(viewModel: viewModel)
                await navigationController?.pushViewController(viewController, animated: true)
            }
        }
        
        @MainActor
        func makeProfileViewController(from annotation: PostAnnotation, in annotations: [Annotation]) async throws -> ProfileViewController {
            let viewModel = try await profileContainer.makeProfileViewModelFromAnnotation(annotation, in: annotations)
            let viewController = ProfileViewController(viewModel: viewModel)
            return viewController
        }
    }
}
