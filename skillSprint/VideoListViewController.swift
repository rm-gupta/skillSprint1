//
//  VideoListViewController.swift
//  skillSprint
//
//  Created by Jeanie Ho on 10/22/24.
//

import UIKit
import AVKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class VideoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var videoURLs: [URL] = []
    var videoIDs: [String] = []
    let db = Firestore.firestore()

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
//        let storageRef = Storage.storage().reference().child("videos")
        // List all items in the "videos" folder
//        storageRef.listAll { (result, error) in
//            if let error = error {
//                print("Error listing videos: \(error)")
//                return
//            }
//            
//            for item in result!.items {
//                // Get the download URL for each video
//                item.downloadURL { (url, error) in
//                    if let error = error {
//                        print("Error getting download URL: \(error)")
//                        return
//                    }
//                    
//                    if let url = url {
//                        self.videoURLs.append(url)
//                        self.videoIDs.append(item.name)
//                        DispatchQueue.main.async {
//                            self.tableView.reloadData()
//                        }
//                    }
//                }
//            }
//        }
        
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }
        // Fetch the user's skills subcollection
        db.collection("users").document(userID).collection("skills").getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }

            if let error = error {
                print("Error fetching user's skills: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No videos found in user's skills collection.")
                return
            }

            // Populate videoURLs and videoIDs with data from the user's skills collection
            self.videoURLs = documents.compactMap { document in
                if let urlString = document.data()["url"] as? String, let url = URL(string: urlString) {
                    return url
                }
                return nil
            }

            self.videoIDs = documents.map { $0.documentID }

            // Reload the table view on the main thread
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoURLs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath)
        cell.backgroundColor = ColorThemeManager.shared.backgroundColor
        cell.contentView.backgroundColor = ColorThemeManager.shared.backgroundColor
        
        let videoID = videoIDs[indexPath.row]
        let videoFileName = videoURLs[indexPath.row].lastPathComponent
        cell.textLabel?.text = "\(videoID): \(videoFileName)"
        cell.textLabel?.textColor = .black
//        cell.textLabel?.text = videoURLs[indexPath.row].lastPathComponent
//        cell.textLabel?.textColor = .black
        return cell
    }

    // MARK: - TableView Delegate Method (Play Video when tapped)
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedVideoURL = videoURLs[indexPath.row]
//        playVideo(from: selectedVideoURL)
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedVideoURL = videoURLs[indexPath.row]
        let selectedVideoID = videoIDs[indexPath.row]
        
        // Create the interactive video player
        let interactivePlayerVC = InteractiveVideoPlayerViewController()
        interactivePlayerVC.videoURL = selectedVideoURL
        interactivePlayerVC.videoID = selectedVideoID
        
        // Set up the player
        let player = AVPlayer(url: selectedVideoURL)
        interactivePlayerVC.player = player
        
        present(interactivePlayerVC, animated: true) {
            player.play()
        }
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
        tableView.backgroundColor = ColorThemeManager.shared.backgroundColor
    }
}
