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
        count: Int = 50,
        offline: Bool = false,
        videoOnly: Bool = false,
        onPostReady: ((Post.Model) -> Void)? = nil
    ) -> [Post.Model] {
        
        if videoOnly {
            let videoURLs = allLocalVideos()
            print("Mock video URLs count:", videoURLs.count)
            let users = MockUserProvider.generateUsers(count: 10, offline: offline)
            let center = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
            let posts: [Post.Model] = (0..<count).map { index in
                let postId = UUID()
                let coordinate = CLLocationCoordinate2D(
                    latitude: center.latitude + Double.random(in: -0.01...0.01),
                    longitude: center.longitude + Double.random(in: -0.01...0.01)
                )
                let url = videoURLs[index % videoURLs.count]
                let media = MediaContent(
                    postId: postId,
                    url: url,
                    isVideo: true,
                    thumbnailURL: nil,
                    isVertical: true
                )
                let content = PostContent.media(media)
                let comments = (0..<Int.random(in: 0...15)).map { _ in
                    generateRandomChineseComment(authors: users)
                }
                let authorUser = users.randomElement()!
                let post = Post.Model(
                    id: postId,
                    coordinate: CodableCoordinate(from: coordinate),
                    text: generateRandomTitle(),
                    content: content,
                    score: Int.random(in: 1...100),
                    author: toPostAuthor(from: authorUser),
                    comments: comments
                )

                // 🔥 Génération du thumbnail en arrière-plan
                UIImage.thumbnailFromVideoAsync(url: url) { image in
                    media.thumbnailImage = image
                    onPostReady?(post)
                }

                return post
            }
            return posts
        }
        
        let imageIDs = [0, 10, 15, 20, 24, 33, 42, 55, 66, 72, 89, 90, 100, 123, 132, 150, 169, 180]
        let localImageNames = localImages
        let center = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let users = MockUserProvider.generateUsers(count: 10, offline: offline)

        let posts: [Post.Model] = (0..<count).map { index in
            let postId = UUID()
            let latOffset = Double.random(in: -0.01...0.01)
            let lonOffset = Double.random(in: -0.01...0.01)
            let coordinate = CLLocationCoordinate2D(
                latitude: center.latitude + latOffset,
                longitude: center.longitude + lonOffset
            )

            let contentType = Int.random(in: 0...2)
            let content: PostContent

            switch contentType {
            case 0:
                if offline {
                    let name = localImageNames.randomElement()!
                    if let image = loadLocalImage(named: name) {
                        let media = MediaContent(localImage: image, isVideo: false)
                        media.isDark = image.isDark(verticalFraction: 4, verticalIndex: 4)
                        content = .media(media)
                    } else {
                        fatalError("Image locale non trouvée : \(name)")
                    }
                } else {
                    let imageID = imageIDs.randomElement()!
                    let url = URL(string: "https://picsum.photos/id/\(imageID)/300/300")!
                    let media = MediaContent(postId: postId, url: url, isVideo: false)
                    content = .media(media)
                }

            case 1...2:
                if offline {
                    let gallery: [MediaContent] = (2..<Int.random(in: 4...10)).compactMap { _ in
                        let name = localImageNames.randomElement()!
                        if let image = loadLocalImage(named: name) {
                            let media = MediaContent(localImage: image, isVideo: false)
                            media.isDark = image.isDark(verticalFraction: 4, verticalIndex: 4)
                            return media
                        }
                        return nil
                    }
                    content = .gallery(gallery)
                } else {
                    let gallery: [MediaContent] = (2..<Int.random(in: 4...10)).map { _ in
                        let id = imageIDs.randomElement()!
                        let url = URL(string: "https://picsum.photos/id/\(id)/300/300")!
                        return MediaContent(postId: postId, url: url, isVideo: false)
                    }
                    content = .gallery(gallery)
                }

            default:
                fatalError("Unexpected contentType")
            }

            let comments = (0..<Int.random(in: 0...15)).map { _ in
                generateRandomChineseComment(authors: users)
            }
            
            let authorUser = users.randomElement()!
            
            return Post.Model(
                id: postId,
                coordinate: CodableCoordinate(from: coordinate),
                text: MockPostProvider.generateRandomTitle(),
                content: content,
                score: Int.random(in: 1...100),
                author: toPostAuthor(from: authorUser),
                comments: comments
            )
        }

        if !offline {
            for post in posts {
                switch post.content {
                case .media(let media):
                    loadCachedImage(from: media.thumbnailURL ?? media.url) { image in
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
                        loadCachedImage(from: media.thumbnailURL ?? media.url) { image in
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
                            onPostReady?(post)
                        }
                    }
                }

                if let avatarURL = post.author.avatarURL {
                    preloadImage(from: avatarURL)
                }
            }
        } else {
            print("📦 Mode offline activé, on appelle onPostReady manuellement")
            for post in posts {
                onPostReady?(post)
            }
        }

        return posts
    }
    
    static func generateMockMapAnnotationsSync(
        count: Int = 50,
        offline: Bool = false,
        videoOnly: Bool = false
    ) -> [Post.Model.MapAnnotation] {
        let posts = generateMockPosts(count: count, offline: offline, videoOnly: videoOnly)
        
        return posts.map { post in
            Post.Model.MapAnnotation(
                id: post.id,
                coordinate: post.coordinate.toCLLocationCoordinate2D(),
                thumbnail: post.firstMedia?.thumbnailImage,
                score: post.score,
                authorId: post.author.id
            )
        }
    }
    
    private static func preloadImage(from url: URL?) {
        guard let url else { return }
        
        let key = url.absoluteString as NSString
        if ImageCache.shared.object(forKey: key) != nil {
            return // déjà en cache
        }

        DispatchQueue.global(qos: .utility).async {
            guard let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else {
                return
            }
            ImageCache.shared.setObject(image, forKey: key, cost: data.count)
        }
    }
    
    private static func toPostAuthor(from user: User) -> PostAuthor {
        return PostAuthor(
            id: user.id,
            username: user.username,
            avatarURL: user.avatarURL,
            followersCount: user.followers.count
        )
    }

    private static func loadLocalImage(named name: String) -> UIImage? {
        let image = UIImage(named: name)
        return image
    }

    private static func generateRandomChineseComment(authors: [User]) -> Post.Comment {
        let sampleComments = [
            "这个帖子太棒了！", "我也想去这里！", "风景真美！", "视频拍得很好 👏", "谢谢分享 ❤️",
            "这是什么地方？", "我曾经去过那里，超赞！", "哈哈哈，好有趣 😄", "太酷了！", "感觉很温馨 ☺️"
        ]
        let author = authors.randomElement()!
        let text = sampleComments.randomElement()!
        return Post.Comment(author: author, text: text)
    }
    
    private static func generateRandomTitle() -> String {
        let samples = [
            // — Courts
            "Vibes only 🌞",
            "Lost in the city.",
            "Chasing sunsets.",
            "Coffee first ☕️",
            "Pure magic.",
            "Unreal moment.",
            "My happy place.",
            "Night drive.",
            "Dream big.",
            "Found this.",
            "Missing this.",
            "Silent thoughts.",
            "Feeling blessed.",
            "Just wow.",
            "Epic.",
            
            // — Moyens
            "Finally found my new favorite café in town, and the latte art is insane!",
            "Life’s too short for boring mornings. Here’s to new beginnings!",
            "This playlist on repeat all day. Anyone else obsessed with chill beats lately?",
            "When the city lights reflect on wet asphalt, it feels like walking through a painting.",
            "Good company and good weather, what more could you ask for?",
            "Didn’t expect this park to be so peaceful at sunset.",
            "All these memories in just a single photo.",
            "Sometimes you just have to say yes and see where the road takes you.",
            "Unexpected adventure with my favorite people.",
            "Snapshots from a day I never want to forget.",
            
            // — Longs
            "Sometimes, all you need is a little change of scenery and suddenly the world feels full of new possibilities. This hidden street café turned my day around, met a stranger who became a friend, and I left with a smile I didn’t know I had in me.",
            "Woke up early just to catch the sunrise over the city. It’s crazy how peaceful everything feels before the world wakes up. Highly recommend trying it at least once, you see things you’d usually miss.",
            "Took a break from my usual routine to explore a new neighborhood, got lost, and ended up in the coziest little bookstore where I spent hours chatting with the owner and left with a stack of stories to read.",
            "It’s not every day you find yourself caught in the rain, running for cover with strangers, laughing so hard you forget you’re soaked. Sometimes it’s the unexpected moments that remind you how good life can be.",
            "Walked along the river after a tough week, headphones in, just watching the city move around me. Found some peace in the chaos and snapped this photo to remember that even on hard days, there’s beauty to be found.",
            "After a long, busy week, nothing felt better than escaping to the park with a book, shutting out the noise, and just enjoying the sun on my face. Moments like these remind me to slow down and breathe.",
            "The city felt different tonight: the lights a little softer, the air warmer, and every street corner filled with possibilities. Grateful for the little adventures that come from saying yes to something new, even if it’s just a walk around the block.",
            "Sometimes, what starts as a random walk turns into a whole story—tonight I met a busker playing my favorite song, shared a smile with a stranger, and realized how connected we all are, even for just a moment.",
            "Today I realized that the things we remember most aren’t the plans we made, but the surprises along the way: the wrong turns, the unexpected laughter, the random acts of kindness from people we’ll never meet again.",
            "This post is just a reminder to myself: keep chasing the little moments that make you feel alive, whether it’s getting lost, making new friends, or just watching the world go by from a quiet corner café."
        ]
        
        var title = samples.randomElement()!
        // Parfois on génère un titre un peu plus long
        if Bool.random() {
            title += " " + samples.randomElement()!
            if title.count > 200 { title = String(title.prefix(200)) }
        }
        return title
    }

    private static func loadCachedImage(from url: URL?, completion: @escaping (UIImage?) -> Void) {
        guard let url else {
            completion(nil)
            return
        }

        let key = url.absoluteString as NSString

        if let cachedImage = ImageCache.shared.object(forKey: key) {
            completion(cachedImage)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            ImageCache.shared.setObject(image, forKey: key, cost: data.count)
            DispatchQueue.main.async { completion(image) }
        }
    }
    
    private static func allLocalVideos() -> [URL] {
        let fileManager = FileManager.default
        guard let resourcePath = Bundle.main.resourcePath else { return [] }
        // Liste tous les fichiers dans le bundle (y compris sous-dossiers)
        let enumerator = fileManager.enumerator(atPath: resourcePath)
        var result: [URL] = []
        while let element = enumerator?.nextObject() as? String {
            if element.hasSuffix(".mp4") {
                let url = URL(fileURLWithPath: resourcePath).appendingPathComponent(element)
                result.append(url)
            }
        }
        print("Vidéos trouvées dans bundle :", result.map { $0.lastPathComponent })
        return result
    }
    
    private static func firstLocalVideo() -> [URL] {
        let fileManager = FileManager.default
        guard let resourcePath = Bundle.main.resourcePath else { return [] }
        
        let enumerator = fileManager.enumerator(atPath: resourcePath)
        while let element = enumerator?.nextObject() as? String {
            if element.hasSuffix(".mp4") {
                let url = URL(fileURLWithPath: resourcePath).appendingPathComponent(element)
                print("Première vidéo trouvée dans bundle :", url.lastPathComponent)
                return [url]
            }
        }
        
        print("Aucune vidéo trouvée dans le bundle")
        return []
    }
}
