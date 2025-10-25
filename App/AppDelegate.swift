//
//  AppDelegate.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 08/04/2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var appCoordinator: AppCoordinator?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        let appCoordinator = AppCoordinator(window: window, env: .mock)
        self.appCoordinator = appCoordinator
        appCoordinator.start(destination: .home)
        return true
    }
}
 
