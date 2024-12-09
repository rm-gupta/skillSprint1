//
//  LeaderboardViewController.swift
//  skillSprint
//
//  Created by Ritu Gupta on 12/8/24.
//

import UIKit
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth

struct LeaderboardUser {
    let id: String
    let username: String
    let name: String
    let score: Int
    let profileImageURL: String?
}

class LeaderboardViewController: UIViewController {
    private let database = Database.database().reference() // Realtime Database
    private let firestore = Firestore.firestore() // Firestore
    private var leaderboard: [LeaderboardUser] = [] // Stores leaderboard data

    private let podiumView = UIView() // For the top 3 users
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "LeaderboardCell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchLeaderboard()
        applyTheme()
    }
    
    private func applyTheme() {
        view.backgroundColor = ColorThemeManager.shared.backgroundColor
    }

    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#FFFEF4")
        title = "Leaderboard"

        // Add podium view for top 3 users
        podiumView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(podiumView)
        NSLayoutConstraint.activate([
            podiumView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            podiumView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            podiumView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            podiumView.heightAnchor.constraint(equalToConstant: 200) // Adjust height as needed
        ])

        // Add table view for remaining users
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self // Assign delegate
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: podiumView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupPodiumView(topUsers: [LeaderboardUser]) {
        podiumView.subviews.forEach { $0.removeFromSuperview() } // Clear previous views

           guard topUsers.count >= 3 else { return }

           // Create views for the top 3 users
           let secondPlaceView = createPodiumUserView(user: topUsers[1], position: 2)
           let firstPlaceView = createPodiumUserView(user: topUsers[0], position: 1)
           let thirdPlaceView = createPodiumUserView(user: topUsers[2], position: 3)

           podiumView.addSubview(secondPlaceView)
           podiumView.addSubview(firstPlaceView)
           podiumView.addSubview(thirdPlaceView)

           // Constraints for second place (left)
           NSLayoutConstraint.activate([
               secondPlaceView.centerYAnchor.constraint(equalTo: podiumView.centerYAnchor, constant: 30),
               secondPlaceView.leadingAnchor.constraint(equalTo: podiumView.leadingAnchor, constant: 10),
               secondPlaceView.widthAnchor.constraint(equalToConstant: 100),
               secondPlaceView.heightAnchor.constraint(equalToConstant: 150)
           ])

           // Constraints for first place (center, with upward offset)
           NSLayoutConstraint.activate([
               firstPlaceView.topAnchor.constraint(equalTo: podiumView.topAnchor, constant: 15), // Move up
               firstPlaceView.centerXAnchor.constraint(equalTo: podiumView.centerXAnchor),
               firstPlaceView.widthAnchor.constraint(equalToConstant: 120),
               firstPlaceView.heightAnchor.constraint(equalToConstant: 180)
           ])

           // Constraints for third place (right)
           NSLayoutConstraint.activate([
               thirdPlaceView.centerYAnchor.constraint(equalTo: podiumView.centerYAnchor, constant: 30),
               thirdPlaceView.trailingAnchor.constraint(equalTo: podiumView.trailingAnchor, constant: -10),
               thirdPlaceView.widthAnchor.constraint(equalToConstant: 100),
               thirdPlaceView.heightAnchor.constraint(equalToConstant: 150)
           ])
    }

    private func createPodiumUserView(user: LeaderboardUser, position: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        // Profile Image
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.clipsToBounds = true
        imageView.backgroundColor = .gray // Placeholder
        if let profileImageURL = user.profileImageURL {
            imageView.loadImage(from: profileImageURL) // Load image from URL
        }

        // Name Label
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = user.name
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        nameLabel.numberOfLines = 1
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.7

        // Username Label
        let usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.text = user.username
        usernameLabel.textAlignment = .center
        usernameLabel.font = UIFont.systemFont(ofSize: 12)
        usernameLabel.textColor = .gray

        // Points Label
        let pointsLabel = UILabel()
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        pointsLabel.text = "\(user.score) points"
        pointsLabel.textAlignment = .center
        pointsLabel.font = UIFont.systemFont(ofSize: 12)

        // Add to Container
        container.addSubview(imageView)
        container.addSubview(nameLabel)
        container.addSubview(usernameLabel)
        container.addSubview(pointsLabel)

        // Constraints
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            usernameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            usernameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            pointsLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 5),
            pointsLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            pointsLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            pointsLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    private func fetchLeaderboard() {
        fetchFriends { friendIDs in
            self.fetchScoresAndDetails(friendIDs: friendIDs) { users in
                self.leaderboard = users.sorted { $0.score > $1.score }

                // Set up the podium for the top 3 users
                if self.leaderboard.count >= 3 {
                    let topThree = Array(self.leaderboard.prefix(3))
                    self.setupPodiumView(topUsers: topThree)
                }

                // Reload the table view for the rest
                self.tableView.reloadData()
            }
        }
    }

    private func fetchFriends(completion: @escaping ([String]) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        database.child("users").child(currentUserID).child("friends").observeSingleEvent(of: .value) { snapshot in
            var friendIDs: [String] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let friendID = snapshot.value as? String {
                    friendIDs.append(friendID)
                }
            }
            // Include the current user in the leaderboard
            friendIDs.append(currentUserID)
            completion(friendIDs)
        }
    }

    private func fetchScoresAndDetails(friendIDs: [String], completion: @escaping ([LeaderboardUser]) -> Void) {
        var leaderboard: [LeaderboardUser] = []
        let group = DispatchGroup()
        
        for friendID in friendIDs {
            group.enter()
            firestore.collection("users").document(friendID).getDocument { snapshot, error in
                guard let snapshot = snapshot, snapshot.exists, let scoreData = snapshot.data() else {
                    group.leave()
                    return
                }
                
                let score = scoreData["score"] as? Int ?? 0
                let profileImageURL = scoreData["profileImageURL"] as? String
                
                // Fetch details from Realtime Database for name and username
                self.database.child("users").child(friendID).observeSingleEvent(of: .value) { userSnapshot in
                    let userData = userSnapshot.value as? [String: Any]
                    let rawUsername = userData?["username"] as? String
                    let name = userData?["name"] as? String
                    
                    // Add @ symbol to username if it exists
                    let username = rawUsername != nil ? "@\(rawUsername!)" : nil
                    
                    // Only add users with valid name and username
                    if let username = username, let name = name {
                        let user = LeaderboardUser(
                            id: friendID,
                            username: username,
                            name: name,
                            score: score,
                            profileImageURL: profileImageURL
                        )
                        leaderboard.append(user)
                    } else {
                        print("Skipping user \(friendID) due to missing name or username.")
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(leaderboard)
        }
    }
}

extension LeaderboardViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(0, leaderboard.count - 3) // Exclude top 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath)
        let user = leaderboard[indexPath.row + 3] // Offset for top 3
        cell.textLabel?.text = "\(indexPath.row + 4). \(user.name) (\(user.username)) - \(user.score) points"
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - UIImageView Extension for Loading Images
extension UIImageView {
    func loadImage(from url: String) {
        guard let imageUrl = URL(string: url) else {
            self.image = UIImage(named: "defaultProfile")
            return
        }
        URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }.resume()
    }
}
