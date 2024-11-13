//
//  EditProfileViewController.swift
//  skillSprint
//
//  Created by Ritu Gupta on 10/22/24.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var profImage: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var taglineField: UITextField!
    @IBOutlet weak var uploadPhoto: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var delegateText: UIViewController!
    var selectedImage: UIImage? = nil
    var currentName: String?
    var currentTagline: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Code to make frame circular and make photo fit in bounds
        profImage.layer.cornerRadius = profImage.frame.size.width / 2
        profImage.clipsToBounds = true

        // Load the current values for name and tagline
        nameField.text = currentName
        taglineField.text = currentTagline
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Load the profile image URL from UserDefaults
        if let imageUrlString = UserDefaults.standard.string(forKey: "profileImageURL"),
        let imageUrl = URL(string: imageUrlString) {

            // Fetch the image from the URL
            fetchProfileImage(from: imageUrl) { [weak self] image in
        
                // Make sure to update the UI on the main thread
                DispatchQueue.main.async {
                    self?.profImage.image = image // Update the ImageView with the fetched image

                }
            }

        }

    }

    // Function to fetch the profile image from a URL
    func fetchProfileImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching image: \(error.localizedDescription)")
                completion(nil) // Return nil if there's an error
                return
            }
            
            // Ensure that the response is valid and data is not nil
            guard let data = data else {
                print("No data returned")
                completion(nil)
                return
            }

            // Convert data to image
            if let image = UIImage(data: data) {
                completion(image)

            } else {
                print("Error converting data to image")
                completion(nil) // Return nil if conversion fails
            }
        }
        task.resume() // Start the data task
    }

    
    // If the save button is pressed, this saves that info
    @IBAction func saveButtonPressed(_ sender: Any) {
        // Ensure that delegateText conforms to both TextChanger and ProfileImageUpdater protocols
        if let otherVC = delegateText as? TextChanger & ProfileImageUpdater {
            guard let userId = Auth.auth().currentUser?.uid else { return }

            // Database reference to the current user's profile
            let ref = Database.database().reference().child("users").child(userId)

            // Create a dictionary to hold the updated fields
            var updates: [String: Any] = [:]

            // Check if nameField has a non-empty string, otherwise, keep the existing name
            if let newName = nameField.text, !newName.isEmpty {
                otherVC.changeName(newName: newName) // Update delegate
                updates["name"] = newName // Add to database update dictionary

            }

            // Check if taglineField has a non-empty string, otherwise, keep the existing tagline
            if let newTagline = taglineField.text, !newTagline.isEmpty {
                otherVC.changeTagline(newTagline: newTagline) // Update delegate
                updates["tagline"] = newTagline // Add to database update dictionary
            }

            // Update the Firebase database with new values for the current user
            ref.updateChildValues(updates) { error, _ in
                if let error = error {
                    print("Error updating database: \(error.localizedDescription)")
                } else {
                    print("Profile updated successfully!")
                    }
                }

                    
            // Dismiss the current view controller after saving
            self.dismiss(animated: true)
        }
    }
    
    // Function to change the user's profile photo
    @IBAction func uploadUserPhoto(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    // Method to upload the selected profile photo to Firebase Storage
    func uploadProfilePhoto(image: UIImage, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        // Create a unique filename for the image
        let filename = UUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_photos/\(filename).jpg")
        
        // Upload the image data
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading photo: \(error)")
                completion(nil) // Call completion with nil on error
                return
            }
            
            // Get the download URL
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting download URL: \(error)")
                    completion(nil) // Call completion with nil on error
                    return
                }
                
                if let downloadURL = url {
                    print("Photo uploaded successfully, download URL: \(downloadURL.absoluteString)")
                    
                    // Save the download URL to UserDefaults
                    UserDefaults.standard.set(downloadURL.absoluteString, forKey: "profileImageURL")
                    print("Stored image URL in UserDefaults")
                    
                    // Call completion with the download URL
                    completion(downloadURL)
                    
                    } else {
                        completion(nil) // Call completion with nil if no URL is returned
                        }

                    }
                }

            }
    }
    
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Get the selected image
            if let image = info[.editedImage] as? UIImage {
                selectedImage = image // Store the selected image
                profImage.image = image // Update the ImageView immediately
                
            } else if let image = info[.originalImage] as? UIImage {
                selectedImage = image // Store the selected image
                profImage.image = image // Update the ImageView immediately
                }

                // Dismiss the image picker
                picker.dismiss(animated: true, completion: nil)

            }
    }

