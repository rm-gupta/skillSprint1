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
    @IBOutlet weak var editProfButton: UIButton!
    
    var currentName: String?
    var currentTagline: String?
    

    
    let greenColor = UIColor(red: 125/255.0, green: 207/255.0, blue: 150/255.0, alpha: 1.0)
    
    // Firebase Database reference
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the Firebase database reference
        ref = Database.database().reference()

        // Set the username label from SharedData
        usernameLabel.text = SharedData.shared.usernameWithAtSymbol
        editProfButton.backgroundColor = greenColor

        // Load profile data for the current user from Firebase
        loadCurrentUserProfile()

        // Add gear icon button
        let settingsButton = UIButton(type: .system)
        let gearImage = UIImage(named: "gearIcon")
        settingsButton.setImage(gearImage, for: .normal)
        settingsButton.tintColor = .black
        settingsButton.frame = CGRect(x: 35, y: 100, width: 30, height: 30)
            
        view.addSubview(settingsButton)

            
        // Add camera shutter icon
        let shutterButton = UIButton(type: .system)
        let shutterImage = UIImage(named: "camShutterIcon")
        shutterButton.setImage(shutterImage, for: .normal)
        shutterButton.tintColor = .black
        shutterButton.frame = CGRect(x: 340, y: 100, width: 30, height: 30)
        view.addSubview(shutterButton)
    }

    func loadCurrentUserProfile() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        // Observe changes to name, tagline, and profile image in real-time
        ref.child("users").child(userID).observe(.value) { snapshot in
            if let userData = snapshot.value as? [String: Any] {
                if let name = userData["name"] as? String {
                    self.nameLabel.text = name
                }

            if let tagline = userData["tagline"] as? String {
                self.taglineLabel.text = tagline
            }

            if let profileImageUrlString = userData["profileImageUrl"] as? String,
                let profileImageUrl = URL(string: profileImageUrlString) {
                self.downloadImage(from: profileImageUrl)
                }
            }
        }
    }

        

    func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
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
        profImgView.image = newImage
        // Code for uploading new image to Firebase Storage and updating profile image URL in the database would go here.
    }
}


