//
//  UserViewModel.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

import Foundation

extension UserFeature.Presentation.ViewModels {
    final class UserViewModel: ObservableObject {
        typealias GetUserUseCase = UserFeature.Application.UseCases.GetUserUseCase
        
        @Published var user: UserFeature.Domain.Entities.User?
        @Published var isLoading = false
        @Published var error: Error?

        private let getUserUseCase: GetUserUseCase

        init(getUserUseCase: GetUserUseCase) {
            self.getUserUseCase = getUserUseCase
        }

        func loadUser(id: String) {
            isLoading = true
            Task {
                do {
                    let response = try await getUserUseCase.execute(request: .init(userId: id))
                    await MainActor.run {
                        self.user = response.user
                        self.isLoading = false
                    }
                } catch {
                    await MainActor.run {
                        self.error = error
                        self.isLoading = false
                    }
                }
            }
        }
    }
}
