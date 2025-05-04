//
//  MockPostProvider.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 14/04/2025.
//

import MapKit
import UIKit

final class MockPostProvider {
    static func generateMockPosts(
        count: Int = 100,
        onPostReady: ((Post.Model) -> Void)? = nil
    ) -> [Post.Model] {
        let imageIDs = [0, 10, 15, 20, 24, 33, 42, 55, 66, 72, 89, 90, 100, 123, 132, 150, 169, 180]
        

        let videoURLs = [
            "https://encrypted-vtbn0.gstatic.com/video?q=tbn:ANd9GcRmeqmn0t6LdG14BuJaeDtTG-vfObVD3l9K1A",
            "https://encrypted-vtbn0.gstatic.com/video?q=tbn:ANd9GcRGRUDePVHuim_iVkUHZCzDurFRxqcfqWKrdA",
            "https://encrypted-vtbn0.gstatic.com/video?q=tbn:ANd9GcQ5fMnVomGrXekgWxO2m2lr8fXd0l_iHUit7g"
        ]
        
        let center = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let users = MockUserProvider.generateUsers(count: 10)

        let posts: [Post.Model] = (0..<count).map { index in
            let latOffset = Double.random(in: -0.01...0.01)
            let lonOffset = Double.random(in: -0.01...0.01)
            let coordinate = CLLocationCoordinate2D(
                latitude: center.latitude + latOffset,
                longitude: center.longitude + lonOffset
            )

            let contentType = Int.random(in: 0...9)
            let content: PostContent

            switch contentType {
            case 0:
                let videoURL = URL(string: videoURLs.randomElement()!)!
                let thumbID = imageIDs.randomElement()!
                let thumbnailURL = URL(string: "https://picsum.photos/id/\(thumbID)/169/300")!
                let isVertical = Bool.random()
                let media = MediaContent(url: videoURL, isVideo: true, thumbnailURL: thumbnailURL, isVertical: isVertical)
                content = .media(media)

            case 1:
                let imageID = imageIDs.randomElement()!
                let url = URL(string: "https://picsum.photos/id/\(imageID)/300/300")!
                let media = MediaContent(url: url, isVideo: false)
                content = .media(media)

            case 2...3:
                let gallery: [MediaContent] = (0..<Int.random(in: 2...4)).map { _ in
                    if Bool.random() {
                        let id = imageIDs.randomElement()!
                        let url = URL(string: "https://picsum.photos/id/\(id)/300/300")!
                        return MediaContent(url: url, isVideo: false)
                    } else {
                        let videoURL = URL(string: videoURLs.randomElement()!)!
                        let thumbID = imageIDs.randomElement()!
                        let thumbnailURL = URL(string: "https://picsum.photos/id/\(thumbID)/169/300")!
                        let isVertical = Bool.random()
                        return MediaContent(url: videoURL, isVideo: true, thumbnailURL: thumbnailURL, isVertical: isVertical)
                    }
                }
                content = .gallery(gallery)

            default:
                let imageID = imageIDs.randomElement()!
                let url = URL(string: "https://picsum.photos/id/\(imageID)/300/300")!
                let media = MediaContent(url: url, isVideo: false)
                content = .media(media)
            }
            
            let comments = (0..<Int.random(in: 0...15)).map { _ in
                generateRandomChineseComment(authors: users)
            }

            return Post.Model(
                id: UUID(),
                coordinate: CodableCoordinate(from: coordinate),
                content: content,
                score: Int.random(in: 1...100),
                author: users.randomElement()!,
                comments: comments
            )
        }

        // ✅ Charger les images après la création
        for post in posts {
            switch post.content {
            case .media(let media):
                loadCachedImage(from: media.thumbnailURL) { image in
                    media.thumbnailImage = image
                    if let image = image {
                        media.isDark = image.isDark(verticalFraction: 4, verticalIndex: 4)
                        onPostReady?(post)
                    }
                }

            case .gallery(let gallery):
                let group = DispatchGroup()

                for media in gallery {
                    group.enter()
                    loadCachedImage(from: media.thumbnailURL) { image in
                        media.thumbnailImage = image
                        if let image = image {
                            media.isDark = image.isDark(verticalFraction: 4, verticalIndex: 4)
                        }
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    let allReady = gallery.allSatisfy { $0.thumbnailImage != nil }
                    if allReady {
                        onPostReady?(post) // Appelle seulement quand TOUTE la gallery est prête
                    }
                }
            }

            if let avatarURL = post.author.avatarURL {
                UIImageView().loadImage(from: avatarURL)
            }
        }

        return posts
    }
    
    private static func generateRandomChineseComment(authors: [User]) -> Post.Comment {
        let sampleComments = [
            "这个帖子太棒了！", "我也想去这里！", "风景真美！", "视频拍得很好 👏", "谢谢分享 ❤️", "这是什么地方？", "我曾经去过那里，超赞！", "哈哈哈，好有趣 😄", "太酷了！", "感觉很温馨 ☺️"
        ]
        let author = authors.randomElement()!
        let text = sampleComments.randomElement()!
        return Post.Comment(author: author, text: text)
    }

    private static func loadImageAsync(from url: URL?, completion: @escaping (UIImage?) -> Void) {
        guard let url = url else {
            completion(nil)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }
    }
    
    private static func loadCachedImage(from url: URL?, completion: @escaping (UIImage?) -> Void) {
        guard let url else {
            completion(nil)
            return
        }

        let key = url.absoluteString as NSString

        // ✅ Si c’est en cache → retour immédiat
        if let cachedImage = ImageCache.shared.object(forKey: key) {
            completion(cachedImage)
            return
        }

        // ✅ Sinon → on attend 5 secondes avant d'aller chercher l'image
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("❌ Failed to load \(url): \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(nil) }
                    return
                }

                guard let data = data,
                      let image = UIImage(data: data),
                      (response as? HTTPURLResponse)?.statusCode == 200 else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }

                ImageCache.shared.setObject(image, forKey: key, cost: data.count)

                DispatchQueue.main.async {
                    completion(image)
                }

            }.resume()
        }
    }
}
