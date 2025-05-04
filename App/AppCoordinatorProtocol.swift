//
//  AppCoordinatorProtocol.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 28/04/2025.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    func start()
}
