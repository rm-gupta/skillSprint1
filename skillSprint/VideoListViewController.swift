//
//  VideoListViewController.swift
//  skillSprint
//
//  Created by Jeanie Ho on 10/22/24.
//

import UIKit
import AVKit
import FirebaseStorage

class VideoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var videoURLs: [URL] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchUploadedVideos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            applyTheme() // Re-apply theme every time the view appears
        }

    // Fetch the list of uploaded video URLs from Firebase Storage
    func fetchUploadedVideos() {
        let storageRef = Storage.storage().reference().child("videos")
        
        // List all items in the "videos" folder
        storageRef.listAll { (result, error) in
            if let error = error {
                print("Error listing videos: \(error)")
                return
            }
            
            for item in result!.items {
                // Get the download URL for each video
                item.downloadURL { (url, error) in
                    if let error = error {
                        print("Error getting download URL: \(error)")
                        return
                    }
                    
                    if let url = url {
                        self.videoURLs.append(url)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoURLs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath)
        cell.textLabel?.text = videoURLs[indexPath.row].lastPathComponent
        return cell
    }

    // MARK: - TableView Delegate Method (Play Video when tapped)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedVideoURL = videoURLs[indexPath.row]
        playVideo(from: selectedVideoURL)
    }

    func playVideo(from url: URL) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    private func applyTheme() {
        view.backgroundColor = ColorThemeManager.shared.backgroundColor
    }
}
