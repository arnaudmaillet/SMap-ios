//
//  PostNamespace.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 05/10/2025.
//


enum PostNamespace: FeatureNamespace {
    enum Data{
        enum DTO {}
        enum Mapper {}
        enum Mock {}
        enum Repository {}
    }
    
    enum Domain {
        enum Entities {}
        enum ValueObjects {}
        enum Services {}
        enum Repositories {}
        enum Errors {}
        enum Events {}
    }
    
    enum Application {
        enum UseCases {}
        enum DTOs {}
        enum Mappers {}
    }
    
    enum Infrastructure {
        enum APIs {}
        enum Persistence {}
        enum Repositories {}
        enum DataSources {}
        enum Factories {}
        
        enum Database {}
    }
    
    enum Presentation {
        enum ViewControllers {}
        enum ViewModels {}
        enum Views {}
        enum Coordinators {}
        enum Validators {}
    }
    
    enum Support {
        enum Mocks {}
    }
    
    enum DI {}
}
