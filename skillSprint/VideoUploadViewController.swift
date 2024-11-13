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

class VideoUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let videoPicker = UIImagePickerController()

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
                        print("Download URL: \(downloadURL.absoluteString)")
                        // Navigate to the next screen and pass the download URL
                        self.navigateToVideoPlayerScreen(with: downloadURL)
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
