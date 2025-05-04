//
//  PostRenderable.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 16/04/2025.
//

import UIKit

protocol PostRenderable {
    var thumbnailURL: URL { get }
    var thumbnailImage: UIImage? { get set }
    var isVideo: Bool { get }
    var isVertical: Bool { get }
}
