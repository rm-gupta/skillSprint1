//
//  EditProfileViewController.swift
//  skillSprint
//
//  Created by Ritu Gupta on 10/22/24.
//

import UIKit
import FirebaseStorage

class EditProfileViewController: UIViewController {

    @IBOutlet weak var profImage: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var taglineField: UITextField!
    @IBOutlet weak var uploadPhoto: UIButton!
    @IBOutlet weak var saveButton: UIButton!
        
    var delegateText: UIViewController!
    var selectedImage: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Code to make frame circular and make photo fit in bounds
        profImage.layer.cornerRadius = profImage.frame.size.width / 2
        profImage.clipsToBounds = true
    }
    
    // If the save button is pressed, this saves that info
    @IBAction func saveButtonPressed(_ sender: Any) {
        // Safely unwrap delegateText and cast it as TextChanger
        if let otherVC = delegateText as? TextChanger {
            let newName = nameField.text ?? "" // Default to empty string if nil
            let newTagline = taglineField.text ?? "" // Default to empty string if nil

            // Call delegate methods with unwrapped values
            otherVC.changeName(newName: newName)
            otherVC.changeTagline(newTagline: newTagline)
            
            // Upload profile photo to Firebase
            if let image = selectedImage {
                uploadProfilePhoto(image: image)
            }
            
            self.dismiss(animated: true)
        } else {
            print("Error: delegateText is nil or doesn't conform to TextChanger.")
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
    func uploadProfilePhoto(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        // Create a unique filename for the image
        let filename = UUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_photos/\(filename).jpg")

        // Upload the image data
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading photo: \(error)")
                return
            }
            
            // Optionally, get the download URL
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting download URL: \(error)")
                    return
                }
                
                if let downloadURL = url {
                    print("Photo uploaded successfully, download URL: \(downloadURL.absoluteString)")
                    
                    // Save the download URL to UserDefaults
                    UserDefaults.standard.set(downloadURL.absoluteString, forKey: "profileImageURL")
                    print("Stored image URL in UserDefaults")
                    
                    // Optionally, you can notify the user or update the UI
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
