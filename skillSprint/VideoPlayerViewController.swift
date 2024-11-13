//
//  VideoPlayerViewController.swift
//  skillSprint
//
//  Created by Jeanie Ho on 10/22/24.
//

import UIKit
import AVKit

class VideoPlayerViewController: UIViewController {

    var videoURL: URL?

    let playerViewController = AVPlayerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()

        if let videoURL = videoURL {
            playVideo(from: videoURL)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            applyTheme() // Re-apply theme every time the view appears
        }

    // Function to play the video using AVPlayer
    func playVideo(from url: URL) {
        let player = AVPlayer(url: url)
        playerViewController.player = player
        
        addChild(playerViewController)
        
        playerViewController.view.frame = self.view.bounds
        self.view.addSubview(playerViewController.view)
        
        playerViewController.didMove(toParent: self)
        
        playerViewController.view.frame = CGRect(x: 10, y: 100, width: self.view.frame.width - 20, height: 300)

        player.play()
    }
    
    private func applyTheme() {
        view.backgroundColor = ColorThemeManager.shared.backgroundColor
    }
        
}
