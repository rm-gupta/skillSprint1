//
//  FriendProfileViewController.swift
//  skillSprint
//
//  Created by Ritu Gupta on 11/13/24.
//

import UIKit
import Firebase
import FirebaseDatabase

class FriendProfileViewController: UIViewController {

    private let user: User
    private var nameLabel: UILabel!
    private var usernameLabel: UILabel!
    private var taglineLabel: UILabel!
    private var friendProfileImg: UIImageView!
    
    // Dependency injection via int
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color and title
        view.backgroundColor = .white
        title = user.username
        print("FriendProfileViewController - viewDidLoad executed")
        self.view.backgroundColor = UIColor(hex: "#FFFEF5")
        
        // Initialize the labels and image view
        setupUI()

        // Ensure that user data is correctly passed
        print("Fetching data for user with ID: \(user.id)")
        fetchUserProfileData()
    }
    
    private func setupUI() {
        // Initialize nameLabel
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .black
        view.addSubview(nameLabel)
        
        // Initialize usernameLabel
        usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = UIFont.systemFont(ofSize: 18)
        usernameLabel.textColor = .gray
        view.addSubview(usernameLabel)
        
        // Initialize taglineLabel
        taglineLabel = UILabel()
        taglineLabel.translatesAutoresizingMaskIntoConstraints = false
        taglineLabel.font = UIFont.systemFont(ofSize: 16)
        taglineLabel.textColor = .darkGray
        view.addSubview(taglineLabel)
        
        // Initialize friendProfileImg
        friendProfileImg = UIImageView()
        friendProfileImg.translatesAutoresizingMaskIntoConstraints = false
        friendProfileImg.contentMode = .scaleAspectFill
        friendProfileImg.layer.cornerRadius = 50
        friendProfileImg.clipsToBounds = true
        view.addSubview(friendProfileImg)

        // Set up Auto Layout constraints
        setupConstraints()
    }
    
    private func setupConstraints() {
        // Set constraints for friendProfileImg (profile image)
        NSLayoutConstraint.activate([
            friendProfileImg.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            friendProfileImg.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            friendProfileImg.widthAnchor.constraint(equalToConstant: 100),
            friendProfileImg.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // Set constraints for nameLabel
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: friendProfileImg.bottomAnchor, constant: 20),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Set constraints for usernameLabel
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Set constraints for taglineLabel
        NSLayoutConstraint.activate([
            taglineLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 10),
            taglineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func fetchUserProfileData() {
        // Get a reference to the Firebase Realtime Database
        let ref = Database.database().reference()
        
        // userID is unique and used to locate the user's data
        ref.child("users").child(user.id).observeSingleEvent(of: .value) { snapshot, error  in
            // Ensure the snapshot contains valid data
            guard let value = snapshot.value as? [String: Any] else {
                print("Error: Data is nil or incorrect format")
                return
            }
            
            // Safely extract user data from Firebase snapshot
            let name = value["name"] as? String ?? "Default Name"
            let username = value["username"] as? String ?? "Default Username"
            let tagline = value["tagline"] as? String ?? "Default Tagline"
            let profileImageURL = value["profileImageURL"] as? String ?? ""
            
            // Safely update the UI on the main thread
            DispatchQueue.main.async {
                print("Updating UI on main thread")
                self.nameLabel.text = name
                self.usernameLabel.text = username
                self.taglineLabel.text = tagline
                
                // Load profile image if the URL exists
                if let imageUrl = URL(string: profileImageURL), !profileImageURL.isEmpty {
                    self.loadImage(from: imageUrl)
                } else {
                    self.friendProfileImg.image = UIImage(named: "defaultProfileImage")
                }
            }
        }
    }
    
    func loadImage(from url: URL) {
        // Use a URLSession to fetch the image data
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image: \(error)")
                return
            }
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.friendProfileImg.image = image
                }
            }
        }.resume()
    }
}
