//
//  PostAnnotationView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 10/04/2025.
//

import UIKit
import MapKit

final class PostAnnotationView: MKAnnotationView {
    static let identifier = "PostAnnotationView"
    private let preview = PostPreviewView()

    override var annotation: MKAnnotation? {
        didSet {
            guard let postAnnotation = annotation as? PostAnnotation else { return }
            preview.configure(with: postAnnotation.post.mediaURL, isVideo: postAnnotation.post.isVideo)
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = "post"
        setupView()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupView() {
        frame = preview.frame
        centerOffset = CGPoint(x: 0, y: -preview.frame.height / 2)
        addSubview(preview)
    }
}
