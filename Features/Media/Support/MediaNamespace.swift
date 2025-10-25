//
//  MediaNamespace.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 07/10/2025.
//

enum MediaNamespace {
    enum Data {
        enum Resolver {}
        enum DTO {}
    }
    
    enum Domain {
        enum Model {}
        enum Contract {}
        
        enum Entities {}
        enum ValueObjects {}
        enum Repositories {}
        enum Services {}
    }
    
    enum UI {
        enum Views {}
        enum ViewModels {}
        enum Loader {}
    }
    
    enum Support {
        enum Mocks {}
    }
    
    enum Application {
        enum UseCases {}
        enum DTOs {}
        enum Mappers {}
        enum Errors {}
    }
    
    enum Infrastructure {
        enum APIs {}
        enum Cache {}
        enum Database {}
        enum DataSources {}
        enum Repositories {}
        enum Services {}
    }
    
    enum Presentation {
        enum Views {}
        enum ViewModels {}
        enum Loader {}
    }
    
    enum DI {}
}
