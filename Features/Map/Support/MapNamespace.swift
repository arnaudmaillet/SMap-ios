//
//  MapNamespace.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 04/10/2025.
//

enum MapFeature {
    enum Container {}
    
    enum Data {
        enum DTO {}
        enum Mapper {}
        enum Mock {}
        enum Repository {}
        enum Service {}
    }
    
    enum Domain {
        enum Model {}
        enum UseCase {}
        
        enum Entities {}
        enum ValueObjects {}
        enum Repository {}
    }
    
    enum UI {
        enum View {}
        enum ViewModel {}
        enum ViewController {}
    }
    
    enum Support {}
    
    enum Application {
        enum DTOs {}
        enum Mappers {}
        enum UseCases {}
    }
    
    enum Infrastructure {
        enum Network {}
        enum Mocks {}
    }
    
    enum Presentation {
        enum ViewControllers {}
        enum ViewModels {}
        enum Views {}
    }
}
