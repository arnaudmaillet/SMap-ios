//
//  PostClusterAnnotationView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 14/04/2025.
//

import UIKit
import MapKit

final class PostClusterAnnotationView: MKAnnotationView {
    static let identifier = "PostClusterAnnotationView"
    private let preview = PostPreviewView()
    private let countLabel = UILabel()
    private var previousSignature: String?

    override var annotation: MKAnnotation? {
        didSet {
            guard let cluster = annotation as? MKClusterAnnotation else { return }

            let signature = cluster.memberAnnotations
                .compactMap { ($0 as? PostAnnotation)?.post.id.uuidString }
                .sorted()
                .joined(separator: "-")

            guard signature != previousSignature else { return }
            previousSignature = signature

            if let bestPost = cluster.memberAnnotations
                .compactMap({ $0 as? PostAnnotation })
                .max(by: { $0.post.score < $1.post.score }) {
                preview.configure(with: bestPost.post.mediaURL, isVideo: bestPost.post.isVideo)
            }

            countLabel.text = "\(cluster.memberAnnotations.count)"
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setup() {
        frame = preview.frame
        centerOffset = CGPoint(x: 0, y: -frame.height / 2)
        addSubview(preview)

        countLabel.font = .boldSystemFont(ofSize: 14)
        countLabel.textColor = .white
        countLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        countLabel.layer.cornerRadius = 10
        countLabel.clipsToBounds = true
        countLabel.textAlignment = .center
        countLabel.frame = CGRect(x: bounds.maxX - 24, y: bounds.minY, width: 24, height: 20)
        addSubview(countLabel)
    }
}
