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
import FirebaseFirestore

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
        applyTheme()
        
        // Code to make frame circular and make photo fit in bounds
        profImage.layer.cornerRadius = profImage.frame.size.width / 2
        profImage.clipsToBounds = true
        
        // Load the current values for name and tagline
        nameField.text = currentName
        taglineField.text = currentTagline
        
        // Add a tap gesture recognizer to dismiss the keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    //Dismisses the keyboard
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
          applyTheme()

          guard let userId = Auth.auth().currentUser?.uid else { return }
          let firestore = Firestore.firestore()

          // Clear the cache to avoid stale data
          URLCache.shared.removeAllCachedResponses()

          // Fetch the profile image URL from Firestore
          firestore.collection("users").document(userId).getDocument { [weak self] document, error in
              if let error = error {
                  print("Error fetching user data: \(error.localizedDescription)")
                  return
              }

              if let document = document, document.exists {
                  let data = document.data()
                  if let imageUrlString = data?["profileImageURL"] as? String,
                     let imageUrl = URL(string: imageUrlString) {
                      print("Fetched profileImageURL: \(imageUrlString)") // Debug log
                      self?.fetchProfileImage(from: imageUrl) { image in
                          DispatchQueue.main.async {
                              self?.profImage.image = image
                          }
                      }
                  } else {
                      print("profileImageURL not found in Firestore")
                  }
              } else {
                  print("User document does not exist")
              }
          }
    }
    
    private func applyTheme() {
        view.backgroundColor = ColorThemeManager.shared.backgroundColor
    }
    
    // Function to fetch the profile image from a URL
    func fetchProfileImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
               if let error = error {
                   print("Error fetching image: \(error.localizedDescription)")
                   completion(nil)
                   return
               }
               
               guard let data = data else {
                   print("No data returned from URL")
                   completion(nil)
                   return
               }
               
               if let image = UIImage(data: data) {
                   completion(image)
               } else {
                   print("Failed to convert data to image")
                   completion(nil)
               }
           }
           task.resume()
    }
    
    
    // If the save button is pressed, this saves that info
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let firestore = Firestore.firestore()
        let ref = Database.database().reference().child("users").child(userId)
        
        // Dictionary to hold updated fields
        var updates: [String: Any] = [:]

        if let newName = nameField.text, !newName.isEmpty {
            updates["name"] = newName
        }

        if let newTagline = taglineField.text, !newTagline.isEmpty {
            updates["tagline"] = newTagline
        }

        // Save changes to Firebase Realtime Database
        ref.updateChildValues(updates) { error, _ in
            if let error = error {
                print("Error updating database: \(error.localizedDescription)")
            } else {
                print("Profile updated in Realtime Database!")
            }
        }

        // Save the profile image if a new image is selected
        if let selectedImage = selectedImage {
            // Update the delegate immediately with the new image
            if let delegate = delegateText as? ProfileImageUpdater {
                delegate.updateProfileImage(newImage: selectedImage)
            }
            
            uploadProfilePhoto(image: selectedImage) { url in
                if let url = url {
                    firestore.collection("users").document(userId).setData(
                        ["profileImageURL": url.absoluteString],
                        merge: true
                    ) { error in
                        if let error = error {
                            print("Error saving profile image URL to Firestore: \(error)")
                        } else {
                            print("Profile image URL saved to Firestore!")
                        }
                    }
                }
            }
        }

        // Dismiss view
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
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
        guard let imageData = image.jpegData(compressionQuality: 0.8),
              let userId = Auth.auth().currentUser?.uid else { return }
        
        // Create a unique filename for the image
        let filename = "\(userId)_profile.jpg"
        let storageRef = Storage.storage().reference().child("profile_photos/\(filename)")
        
        // Upload the image data
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading photo: \(error)")
                completion(nil)
                return
            }
            
            // Get the download URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error)")
                    completion(nil)
                    return
                }
                
                if let downloadURL = url {
                    print("Photo uploaded successfully, download URL: \(downloadURL.absoluteString)")
                    
                    // Save the download URL to Firestore
                    let firestore = Firestore.firestore()
                    firestore.collection("users").document(userId).setData(
                        ["profileImageURL": downloadURL.absoluteString],
                        merge: true
                    ) { error in
                        if let error = error {
                            print("Error saving URL to Firestore: \(error)")
                        } else {
                            print("Profile image URL saved to Firestore!")
                        }
                    }
                    
                    // Call completion with the download URL
                    completion(downloadURL)
                } else {
                    completion(nil)
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

