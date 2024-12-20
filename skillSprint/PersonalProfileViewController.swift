//
//  PersonalProfileViewController.swift
//  skillSprint
//
//  Created by Ritu Gupta on 10/22/24.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

protocol TextChanger {
    func changeName(newName: String)
    func changeTagline(newTagline: String)
}

protocol ProfileImageUpdater {
    func updateProfileImage(newImage: UIImage)
}

class PersonalProfileViewController: UIViewController, TextChanger, ProfileImageUpdater {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var profImgView: UIImageView!
    
    var currentName: String?
    var currentTagline: String?
    private var currentImageURL: String?

 
    let greenColor = UIColor(red: 125/255.0, green: 207/255.0, blue: 150/255.0, alpha: 1.0)
    
    // Firebase Database reference
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()

        // Initialize Firebase database reference
        ref = Database.database().reference()

        // Set the username label from SharedData
        usernameLabel.text = SharedData.shared.usernameWithAtSymbol

        // Add image views to the view hierarchy
        view.addSubview(editProfileImageView)
        view.addSubview(addFriendsImageView)

        // Set constraints for image views
        setUpImageViewConstraints()

        // Add gesture recognizers
        let editProfileTapGesture = UITapGestureRecognizer(target: self, action: #selector(editProfileTapped))
        editProfileImageView.addGestureRecognizer(editProfileTapGesture)

        let addFriendsTapGesture = UITapGestureRecognizer(target: self, action: #selector(addFriendsTapped))
        addFriendsImageView.addGestureRecognizer(addFriendsTapGesture)

        // Load profile data for the current user from Firebase
        loadCurrentUserProfile()
    }
    
    private func setUpImageViewConstraints() {
        editProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        addFriendsImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Edit Profile Image Constraints
            editProfileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            editProfileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            editProfileImageView.widthAnchor.constraint(equalToConstant: 36), // Adjusted size
            editProfileImageView.heightAnchor.constraint(equalToConstant: 36),

            // Add Friends Image Constraints
            addFriendsImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            addFriendsImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addFriendsImageView.widthAnchor.constraint(equalToConstant: 36), // Adjusted size
            addFriendsImageView.heightAnchor.constraint(equalToConstant: 36),
        ])
    }


    
    private let editProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "pencil") // Pencil icon
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let addFriendsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.fill") // Person icon
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    
    @objc func editProfileTapped() {
        print("Edit Profile Tapped")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let editProfileVC = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController else {
            print("EditProfileViewController not found")
            return
        }

        editProfileVC.delegateText = self
        editProfileVC.currentName = nameLabel.text
        editProfileVC.currentTagline = taglineLabel.text

        navigationController?.pushViewController(editProfileVC, animated: true)
    }

    @objc func addFriendsTapped() {
        print("Add Friends Tapped")
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "AddFriendsStoryboard" with the actual storyboard name
        guard let addFriendsVC = storyboard.instantiateViewController(withIdentifier: "AddFriendsViewController") as? AddFriendsViewController else {
            print("AddFriendsViewController not found")
            return
        }

        navigationController?.pushViewController(addFriendsVC, animated: true)
    }
    
    @objc func settingsButtonTapped() {
        let settingsViewController = SettingsViewController()
        present(settingsViewController, animated: true, completion: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
           applyTheme()
           loadCurrentUserProfile()
        }
    
    

    func loadCurrentUserProfile() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

           // Firebase Realtime Database (for name and tagline)
           ref.child("users").child(userID).observe(.value) { snapshot in
               if let userData = snapshot.value as? [String: Any] {
                   if let name = userData["name"] as? String {
                       self.nameLabel.text = name
                   }
                   if let tagline = userData["tagline"] as? String {
                       self.taglineLabel.text = tagline
                   }
               }
           }

           // Firestore Listener (for profile image)
           let firestore = Firestore.firestore()
           firestore.collection("users").document(userID).addSnapshotListener { [weak self] documentSnapshot, error in
               if let error = error {
                   print("Error listening for Firestore updates: \(error.localizedDescription)")
                   return
               }

               guard let document = documentSnapshot, document.exists,
                     let profileImageUrlString = document.data()?["profileImageURL"] as? String,
                     let profileImageUrl = URL(string: profileImageUrlString) else {
                   print("No profile image URL found.")
                   return
               }

               // Debounce updates
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                   self?.downloadImage(from: profileImageUrl)
               }
           }
    }

        

    func downloadImage(from url: URL) {
        // Skip redundant updates
           if currentImageURL == url.absoluteString {
               return
           }

           currentImageURL = url.absoluteString // Update the current URL

           let sessionConfig = URLSessionConfiguration.default
           sessionConfig.requestCachePolicy = .reloadIgnoringLocalCacheData // Ignore cached data

           let session = URLSession(configuration: sessionConfig)
           session.dataTask(with: url) { (data, response, error) in
               guard let data = data, error == nil else {
                   print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
                   return
               }

               DispatchQueue.main.async {
                   if let image = UIImage(data: data) {
                       self.profImgView.image = image
                       print("Image updated successfully.")
                   } else {
                       print("Failed to create image from data.")
                   }
               }
           }.resume()
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditProfileSegue",
            let nextVC = segue.destination as? EditProfileViewController {
                nextVC.delegateText = self
                nextVC.currentName = nameLabel.text
                nextVC.currentTagline = taglineLabel.text
            }
        }


    // If the name field is changed
    func changeName(newName: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        ref.child("users").child(userID).child("name").setValue(newName)
    }

    // If the tagline field is changed
    func changeTagline(newTagline: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        ref.child("users").child(userID).child("tagline").setValue(newTagline)
    }

    func updateProfileImage(newImage: UIImage) {
        // Update the profile image view immediately
           DispatchQueue.main.async {
               self.profImgView.image = newImage
           }

           // Upload the new image to Firebase Storage
           guard let imageData = newImage.jpegData(compressionQuality: 0.8),
                 let userID = Auth.auth().currentUser?.uid else { return }

           let filename = "\(userID)_profile.jpg"
           let storageRef = Storage.storage().reference().child("profile_photos/\(filename)")

           storageRef.putData(imageData, metadata: nil) { metadata, error in
               if let error = error {
                   print("Error uploading photo: \(error.localizedDescription)")
                   return
               }

               // Get the download URL and update Firestore
               storageRef.downloadURL { url, error in
                   if let error = error {
                       print("Error getting download URL: \(error.localizedDescription)")
                       return
                   }

                   if let downloadURL = url {
                       self.currentImageURL = downloadURL.absoluteString // Prevent redundant updates

                       let firestore = Firestore.firestore()
                       firestore.collection("users").document(userID).setData(
                           ["profileImageURL": downloadURL.absoluteString],
                           merge: true
                       ) { error in
                           if let error = error {
                               print("Error saving profileImageURL to Firestore: \(error.localizedDescription)")
                           } else {
                               print("Profile image URL updated in Firestore.")
                           }
                       }
                   }
               }
           }
    }
    
    private func applyTheme() {
        view.backgroundColor = ColorThemeManager.shared.backgroundColor
    }
}


