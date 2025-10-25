//
//  CapsuleListView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 10/10/2025.
//

import UIKit

final class HorizontalCapsuleListView: UIView {

    // MARK: - Properties

    private var items: [String] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.register(CapsuleCell.self, forCellWithReuseIdentifier: CapsuleCell.reuseIdentifier)
        return collectionView
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    // MARK: - Layout

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 24)
    }

    // MARK: - Public

    func configure(with items: [String]) {
        self.items = items
        collectionView.reloadData()
    }
    
    func animateAppearance(visible: Bool) {
        let baseDelay: TimeInterval = 0.025
        let sortedCells = collectionView.visibleCells.sorted {
            let f1 = collectionView.convert($0.frame, to: self).origin.x
            let f2 = collectionView.convert($1.frame, to: self).origin.x
            return f1 < f2
        }

        for (index, cell) in sortedCells.enumerated() {
            let delay = baseDelay * Double(index)

            if visible {
                cell.alpha = 0
                cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }

            UIView.animate(
                withDuration: 0.4,
                delay: delay,
                usingSpringWithDamping: 0.65,
                initialSpringVelocity: 0.7,
                options: [.beginFromCurrentState, .curveEaseOut],
                animations: {
                    cell.alpha = visible ? 1.0 : 0.0
                    cell.transform = visible ? .identity : CGAffineTransform(scaleX: 0.85, y: 0.85)
                }
            )
        }
    }
}

// MARK: - UICollectionViewDataSource

extension HorizontalCapsuleListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CapsuleCell.reuseIdentifier, for: indexPath
        ) as? CapsuleCell else {
            return UICollectionViewCell()
        }

        let item = items[indexPath.item]
        cell.configure(text: item) {
            print("✅ Capsule tapped:", item)
        }

        return cell
    }
}
