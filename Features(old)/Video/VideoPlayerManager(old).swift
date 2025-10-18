//
//  VideoPlayerManager.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 02/07/2025.
//

import UIKit

protocol VideoPlayable: AnyObject {
    var isVisible: Bool { get }
    func play()
    func pause()
}

final class VideoPlayerManager {
    static let shared = VideoPlayerManager()
    private let poolCapacity = 5

    private(set) var playerPool: [VideoPlayerView] = []
    private(set) var assignments: [String: VideoPlayerView] = [:]
    private var usageQueue: [String] = []
    private var standalonePlayers: [String: VideoPlayerView] = [:]
    var forcedMediaIds: Set<String> = []

    private init() {
        playerPool = (0..<poolCapacity).map { _ in VideoPlayerView() }
    }

    // MARK: - Acquisition (pool)

    func assignedPlayer(for mediaId: String) -> VideoPlayerView? {
        assignments[mediaId]
    }

    func isPlayerAssigned(for mediaId: String) -> Bool {
        assignments[mediaId] != nil
    }

    func assignPlayer(for mediaId: String, url: URL) -> VideoPlayerView? {
        // Si un player est déjà assigné, le retourner
        if let existing = assignments[mediaId] {
            return existing
        }
        // Chercher un slot libre dans le pool
        if assignments.count < playerPool.count,
           let available = playerPool.first(where: { !assignments.values.contains($0) }) {
            
            available.configure(with: url, id: UUID(uuidString: mediaId) ?? UUID())
            assignments[mediaId] = available
            usageQueue.append(mediaId)
            return available
        }

        // Sinon, remplacer le plus ancien (non forcé)
        if let oldest = usageQueue.first(where: { !forcedMediaIds.contains($0) }),
           let playerToReuse = assignments[oldest] {

            print("♻️ [assignNewPlayer] Pool plein, remplacement de \(oldest) par \(mediaId)")

            // Cleanup de l'ancien assignment
            assignments.removeValue(forKey: oldest)
            usageQueue.removeAll { $0 == oldest }

            // Rebind du player
            playerToReuse.rebind(url: url, id: UUID(uuidString: mediaId) ?? UUID())
            assignments[mediaId] = playerToReuse
            usageQueue.append(mediaId)

            return playerToReuse
        }

        // Aucun remplacement possible (tout est forcé ?)
        print("⛔️ [assignNewPlayer] Pool plein et aucun remplacement possible")
        return nil
    }

    func migratePlayer(from oldMediaId: String, to newMediaId: String, url: URL) -> VideoPlayerView? {
        guard let player = assignments[oldMediaId] else {
            print("❌ [migratePlayer] \(oldMediaId) non trouvé dans le pool")
            debugPrintPlayerStates()
            return nil
        }

        assignments.removeValue(forKey: oldMediaId)
        usageQueue.removeAll { $0 == oldMediaId }

        assignments[newMediaId] = player
        usageQueue.append(newMediaId)

        player.rebind(url: url, id: UUID(uuidString: newMediaId) ?? UUID())
        return player
    }

    func releasePlayer(for mediaId: String) {
        // Ne pas relâcher si forcé
        if forcedMediaIds.contains(mediaId) {
            print("⛔️ [releasePlayer] \(mediaId) est forcé → skip")
            return
        }

        guard let player = assignments[mediaId] else { return }

        let mediaView = player.superview as? MediaContainerView
        player.removeFromSuperview()

        if let mediaView = mediaView {
            mediaView.videoPlayerView = nil
        }

        player.cleanup()
        assignments.removeValue(forKey: mediaId)
        usageQueue.removeAll { $0 == mediaId }
    }

    func forceRelease(mediaId: String) {
        print("🔓 [forceRelease] Retrait de \(mediaId) des forcés")
        forcedMediaIds.remove(mediaId)
        releasePlayer(for: mediaId)
    }
    
    func releaseAll(except keepIds: Set<String>) {
        for (mid, _) in assignments where !keepIds.contains(mid) {
            releasePlayer(for: mid)
        }
    }

    func releaseAll() {
        for mediaId in assignments.keys {
            releasePlayer(for: mediaId)
        }
    }

    func pauseAll() {
        for player in assignments.values {
            player.pause()
        }
    }

    // MARK: - Standalone Player (hors pool)

    func createStandalonePlayer(for media: MediaContent) -> VideoPlayerView? {
        guard let url = media.url else { return nil }

        if let existing = standalonePlayers[media.id.uuidString] {
            return existing
        }

        let player = VideoPlayerView()
        player.configure(with: url, id: media.id)
        standalonePlayers[media.id.uuidString] = player

        print("📌 [Standalone] Créé player pour bannière: \(media.id)")
        return player
    }

    func releaseStandalonePlayer(for mediaId: String) {
        guard let player = standalonePlayers[mediaId] else { return }

        player.removeFromSuperview()
        player.cleanup()
        standalonePlayers.removeValue(forKey: mediaId)

        print("♻️ [Standalone] Released player pour bannière: \(mediaId)")
    }
    
    func releaseAllStandalone() {
        for mediaId in Array(standalonePlayers.keys) {
            releaseStandalonePlayer(for: mediaId)
        }
    }
    
    func releaseAllStandalone(except keepIds: Set<String>) {
        for (mediaId, _) in standalonePlayers where !keepIds.contains(mediaId) {
            releaseStandalonePlayer(for: mediaId)
        }
    }

    func standalonePlayer(for mediaId: String) -> VideoPlayerView? {
        standalonePlayers[mediaId]
    }

    // MARK: - Debug

    func debugPrintPlayerStates() {
        print("---- VideoPlayerManager ----")
        for (index, player) in playerPool.enumerated() {
            if let (mediaId, _) = assignments.first(where: { $0.value === player }) {
                print("Player[\(index)]: assigned to \(mediaId)")
            } else {
                print("Player[\(index)]: FREE")
            }
        }
        print("Standalone: \(standalonePlayers.keys)")
        print("----------------------------")
    }
}
