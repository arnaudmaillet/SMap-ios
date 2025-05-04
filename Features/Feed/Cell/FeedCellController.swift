//
//  FeedCellController.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 30/04/2025.
//

import UIKit

final class FeedCellController {
    private(set) var cell: FeedCell?
    private var post: Post.Model?

    func configure(cell: FeedCell, with post: Post.Model, safeAreaInsets: UIEdgeInsets) {
        self.cell = cell
        self.post = post
        cell.configure(with: post, safeAreaInsets: safeAreaInsets)
    }
}
