//
//  UserNamespace.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 15/10/2025.
//

enum UserFeature {
    enum Application {
        enum DTOs {}
        enum Mappers {}
        enum UseCases {}
    }
    
    enum Domain {
        enum Entities {}
        enum ValueObjects {}
        enum Repository {}
    }
    
    enum Infrastructure {
        enum Network {}
    }
    
    enum Presentation {
        enum ViewControllers {}
        enum ViewModels {}
        enum Views {}
    }
    
    enum Support {
        enum Mocks {}
    }
}
