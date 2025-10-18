//
//  HomeViewController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 03/10/2025.
//

import UIKit

final class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Si tu veux ajouter un bouton à droite :
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.circle"),
            style: .plain,
            target: self,
            action: #selector(didTapProfile)
        )
    }
    
    @objc private func didTapProfile() {
        print("🔵 Profile tapped")
    }

    func embedMap(_ mapVC: UIViewController) {
        addChild(mapVC)
        view.addSubview(mapVC.view)
        mapVC.view.frame = view.bounds
        mapVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapVC.didMove(toParent: self)
    }
}
