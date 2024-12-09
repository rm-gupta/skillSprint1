//
//  VideoUploadViewController.swift
//  skillSprint
//
//  Created by Jeanie Ho on 10/22/24.
//

import UIKit
import MobileCoreServices
import FirebaseStorage
import UniformTypeIdentifiers // New import for UTType.movie
import FirebaseAuth
import FirebaseFirestore

class VideoUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let videoPicker = UIImagePickerController()
    private let db = Firestore.firestore()
    var selectedSkillID: String? // selected skill id

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        videoPicker.delegate = self
        videoPicker.mediaTypes = [UTType.movie.identifier]
        videoPicker.videoQuality = .typeHigh
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            applyTheme() // Re-apply theme every time the view appears
        }

    // MARK: - Record Video Action
    @IBAction func recordVideo(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            videoPicker.sourceType = .camera
            videoPicker.cameraCaptureMode = .video
            present(videoPicker, animated: true, completion: nil)
        } else {
            print("Camera is not available.")
        }
    }

    // MARK: - Upload Video Action
    @IBAction func uploadVideo(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            videoPicker.sourceType = .photoLibrary
            present(videoPicker, animated: true, completion: nil)
        } else {
            print("Photo library is not available.")
        }
    }

    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoURL = info[.mediaURL] as? URL {
            uploadVideoToFirebase(fileURL: videoURL)
            BadgeManager.shared.checkBadges()
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func navigateToVideoPlayerScreen(with videoURL: URL) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) 
        if let videoPlayerVC = storyboard.instantiateViewController(identifier: "VideoPlayerViewController") as? VideoPlayerViewController {
            videoPlayerVC.videoURL = videoURL
            self.navigationController?.pushViewController(videoPlayerVC, animated: true)
        }
    }

    // MARK: - Upload Video to Firebase
    func uploadVideoToFirebase(fileURL: URL) {
        guard let userID = Auth.auth().currentUser?.uid else {
                print("User is not authenticated.")
                return
            }
        if selectedSkillID == nil {
            if let skillForToday = UserDefaults.standard.string(forKey: "skillForToday") {
                selectedSkillID = skillForToday
                print("Using skillForToday as selectedSkillID: \(skillForToday)")
            } else {
                print("No skill selected and no skillForToday found.")
                return // Exit if no fallback is available
            }
        }
        let filename = UUID().uuidString
        let ref = Storage.storage().reference().child("videos").child("\(filename).mp4")

        do {
            let videoData = try Data(contentsOf: fileURL)
            ref.putData(videoData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading video: \(error.localizedDescription)")
                    return
                }

                // Get the download URL for the uploaded video
                ref.downloadURL { url, error in
                    if let error = error {
                        print("Failed to get download URL: \(error.localizedDescription)")
                        return
                    }
                    
                    if let downloadURL = url {
                        // Create a Firestore document for the video
                        let videoDocument: [String: Any] = [
                            "url": downloadURL.absoluteString,
                            "likes": 0,
                            "likedBy": [],
                            "uploadedAt": FieldValue.serverTimestamp(),
                            "skillID": self.selectedSkillID!
                        ]
                        
                        self.db.collection("videos").document(filename).setData(videoDocument)
                        
                        self.db.collection("users")
                            .document(userID)
                            .collection("skills")
                            .document(self.selectedSkillID!)
                            .setData(videoDocument) { error in
                                if let error = error {
                                    print("Error saving video data: \(error.localizedDescription)")
                                } else {
                                    print("Video data successfully saved.")
                                }
                            }
                        // Navigate to video player
                        DispatchQueue.main.async {
                            self.navigateToVideoPlayerScreen(with: downloadURL)
                        }
                    }
                }
            }
        } catch {
            print("Failed to get video data: \(error)")
        }
        
        
    }
    
    private func applyTheme() {
        view.backgroundColor = ColorThemeManager.shared.backgroundColor
    }

}
