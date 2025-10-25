//
//  MediaView.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 07/10/2025.
//

import UIKit
import AVFoundation
import Combine

extension MediaNamespace.Presentation.Views {
    final class MediaView: UIView {
        typealias MediaViewModel = MediaNamespace.Presentation.ViewModels.MediaViewModel
        typealias VideoPlayerView = MediaNamespace.Presentation.Views.VideoPlayerView
        
        private let imageView = UIImageView()
        private let videoView = VideoPlayerView()
        private var cancellables = Set<AnyCancellable>()
        private var viewModel: MediaViewModel?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupViews() {
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            videoView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(imageView)
            addSubview(videoView)
            
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: topAnchor),
                imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
                
                videoView.topAnchor.constraint(equalTo: topAnchor),
                videoView.bottomAnchor.constraint(equalTo: bottomAnchor),
                videoView.leadingAnchor.constraint(equalTo: leadingAnchor),
                videoView.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
        }
        
        func configure(with viewModel: MediaViewModel) {
            self.viewModel = viewModel
            
            viewModel.$image
                .receive(on: DispatchQueue.main)
                .sink { [weak self] image in
                    guard let image = image else { return }
                    self?.imageView.image = image
                    self?.imageView.isHidden = false
                }
                .store(in: &cancellables)
            
            viewModel.$isPlayerReady
                .receive(on: DispatchQueue.main)
                .sink { [weak self] ready in
                    guard ready, let player = viewModel.player else { return }
                    self?.videoView.attachPlayer(player)
                    self?.videoView.play()
                    self?.videoView.isHidden = false
                    self?.imageView.isHidden = true
                }
                .store(in: &cancellables)
            
            viewModel.load()
        }
        
        func stopPlayback() {
            videoView.stop()
        }
    }
}
