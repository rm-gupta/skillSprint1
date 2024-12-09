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
    private var achievementsButton: UIButton!
    
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
        applyTheme()
    }
    private func applyTheme() {
        view.backgroundColor = ColorThemeManager.shared.backgroundColor
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
//        friendProfileImg = UIImageView()
//        friendProfileImg.translatesAutoresizingMaskIntoConstraints = false
//        friendProfileImg.contentMode = .scaleAspectFill
//        friendProfileImg.layer.cornerRadius = 50
//        friendProfileImg.clipsToBounds = true
//        view.addSubview(friendProfileImg)
        friendProfileImg = UIImageView()
        friendProfileImg.translatesAutoresizingMaskIntoConstraints = false
        friendProfileImg.contentMode = .scaleAspectFit
        friendProfileImg.tintColor = .gray // Set tint for SF Symbol
        friendProfileImg.backgroundColor = UIColor.systemGray5 // Optional background color
        friendProfileImg.layer.cornerRadius = 75 // Adjust to match larger size
        friendProfileImg.clipsToBounds = true
        view.addSubview(friendProfileImg)
        
        // Initialize the Achievements button
        achievementsButton = UIButton(type: .system)
        achievementsButton.translatesAutoresizingMaskIntoConstraints = false
        achievementsButton.setTitle("View Achievements", for: .normal)
        achievementsButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        achievementsButton.setTitleColor(.white, for: .normal)
        achievementsButton.layer.cornerRadius = 5
        achievementsButton.backgroundColor = UIColor(hex: "#7DCF96")
        achievementsButton.addTarget(self, action: #selector(viewAchievementsTapped), for: .touchUpInside)
        
        view.addSubview(achievementsButton)

        // Set up Auto Layout constraints
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Move the profile image further up by decreasing the constant
            friendProfileImg.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            friendProfileImg.topAnchor.constraint(equalTo: view.topAnchor, constant: 150), // Reduced value to move it up
            friendProfileImg.widthAnchor.constraint(equalToConstant: 150), // Profile image size
            friendProfileImg.heightAnchor.constraint(equalToConstant: 150) // Profile image size
        ])

        NSLayoutConstraint.activate([
            // Position the name label relative to the profile image
            nameLabel.topAnchor.constraint(equalTo: friendProfileImg.bottomAnchor, constant: 20), // Reduced value for closer spacing
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            // Position the username label relative to the name label
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8), // Reduced value for closer spacing
            usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            // Position the tagline label relative to the username label
            taglineLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8), // Reduced value for closer spacing
            taglineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            achievementsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            achievementsButton.topAnchor.constraint(equalTo: taglineLabel.bottomAnchor, constant: 15), // Position below the tagline
            achievementsButton.widthAnchor.constraint(equalToConstant: 198), // Set width
            achievementsButton.heightAnchor.constraint(equalToConstant: 35) // Set height
        ])
    }
    
    @objc private func viewAchievementsTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let badgesVC = storyboard.instantiateViewController(withIdentifier: "BadgesViewController") as? BadgesViewController else {
            print("Error: Could not instantiate BadgesViewController")
            return
        }
        
        // Push to the navigation controller if available
        if let navigationController = self.navigationController {
            navigationController.pushViewController(badgesVC, animated: true)
        } else {
            // Present modally if no navigation controller
            badgesVC.modalPresentationStyle = .fullScreen // or .pageSheet/.formSheet
            self.present(badgesVC, animated: true)
        }
    }
    
    private func fetchUserProfileData() {
        let databaseRef = Database.database().reference()
           let firestore = Firestore.firestore()

           // Fetch user details from Realtime Database
           databaseRef.child("users").child(user.id).observeSingleEvent(of: .value) { snapshot in
               guard let value = snapshot.value as? [String: Any] else {
                   print("Error: Data is nil or in incorrect format")
                   return
               }

               // Extract user data
               let name = value["name"] as? String ?? "Default Name"
               let username = value["username"] as? String ?? "Default Username"
               let tagline = value["tagline"] as? String ?? "Default Tagline"

               // Update the labels on the main thread
               DispatchQueue.main.async {
                   self.nameLabel.text = name
                   self.usernameLabel.text = "@\(username)" // Add @ in front of the username
                   self.taglineLabel.text = tagline
               }
           }

           // Fetch the profile image URL from Firestore
           firestore.collection("users").document(user.id).getDocument { snapshot, error in
               if let error = error {
                   print("Error fetching Firestore document: \(error.localizedDescription)")
                   return
               }

               guard let document = snapshot, document.exists,
                     let profileImageURL = document.data()?["profileImageURL"] as? String else {
                   print("No profile image URL found in Firestore")
                   DispatchQueue.main.async {
                       // Set SF Symbol as the default profile image
                       self.friendProfileImg.image = UIImage(systemName: "person.crop.circle")
                       self.friendProfileImg.tintColor = .gray
                   }
                   return
               }

               // Load and update the profile image
               if let imageUrl = URL(string: profileImageURL) {
                   self.loadImage(from: imageUrl)
               } else {
                   DispatchQueue.main.async {
                       self.friendProfileImg.image = UIImage(systemName: "person.crop.circle")
                       self.friendProfileImg.tintColor = .gray
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
