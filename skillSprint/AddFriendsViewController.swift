//  AddFriendsViewController.swift
//  skillSprint
//
//  Created by Ritu Gupta on 11/08/24.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

struct User: Codable {
    let id: String
    let username: String
    let name: String
    let tagline: String
}

// MARK: - Add Friends View Controller
class AddFriendsViewController: UIViewController {
    private let database = Database.database().reference()
    private var filteredUsers: [User] = []
    private var currentUserFriends: Set<String> = []

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users..."
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(EnhancedFriendCell.self, forCellReuseIdentifier: "EnhancedFriendCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegates()
        fetchCurrentUserFriends()
        fetchAllUsers() // Load all users initially
        self.view.backgroundColor = UIColor(hex: "#FFFEF5")
    }

    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCurrentUserFriends()  // Refresh the list of current friends when coming
        updateFilteredUsers()

    }

    

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .white
        title = "Add Friends"

        view.addSubview(searchBar)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    

    private func setupDelegates() {
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - Firebase Methods
    private func fetchCurrentUserFriends() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        database.child("users").child(currentUserID).child("friends").observe(.value) { [weak self] snapshot in

            guard let self = self else { return }
            self.currentUserFriends.removeAll()

            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let friendID = snapshot.value as? String {
                    self.currentUserFriends.insert(friendID)
                }
            }

            self.tableView.reloadData()
        }
    }

    

    //JUST ADDED THIS
    private func fetchAllUsers() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        database.child("users").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }

            self.filteredUsers.removeAll()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let userData = snapshot.value as? [String: Any],
                   let username = userData["username"] as? String,
                   snapshot.key != currentUserID { // Exclude current user

                    let name = userData["savedName"] as? String ?? ""
                    let tagline = userData["savedTagline"] as? String ?? ""

                    let user = User(
                        id: snapshot.key,
                        username: username,
                        name: name,
                        tagline: tagline
                    )

                    
                    // Only add to filtered users if the user is a current friend
                    if self.currentUserFriends.contains(user.id) {
                        self.filteredUsers.append(user)
                    }
                }
            }

            self.tableView.reloadData()
        }
    }

    private func searchUsers(with username: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let normalizedSearchText = normalizeText(username) // Normalize search text for consistency

        database.child("users").queryOrdered(byChild: "username")
            .queryStarting(atValue: normalizedSearchText)
            .queryEnding(atValue: normalizedSearchText + "\u{f8ff}")
            .observeSingleEvent(of: .value) { [weak self] snapshot in

                guard let self = self else { return }

                self.filteredUsers.removeAll()

                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                       let userData = snapshot.value as? [String: Any],
                       let username = userData["username"] as? String,
                       snapshot.key != currentUserID { // Check to exclude current user

                        let name = userData["savedName"] as? String ?? ""
                        let tagline = userData["savedTagline"] as? String ?? ""

                        let user = User(
                            id: snapshot.key,
                            username: username,
                            name: name,
                            tagline: tagline
                        )

                        self.filteredUsers.append(user)
                    }
                }

                self.tableView.reloadData()
            }
    }

    

    private func normalizeText(_ text: String) -> String {
        return text.lowercased().folding(options: .diacriticInsensitive, locale: .current) // Normalize for case and diacritics
    }

    private func addFriend(userID: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        // Add to current user's friends list
        let currentUserFriendRef = database.child("users").child(currentUserID).child("friends").childByAutoId()
        currentUserFriendRef.setValue(userID) { [weak self] error, _ in
           
            if let error = error {
                self?.showAlert(title: "Error", message: error.localizedDescription)
                return
            }

            // Add the other user to the current user's friends list
            let otherUserFriendRef = self?.database.child("users").child(userID).child("friends").childByAutoId()
            otherUserFriendRef?.setValue(currentUserID) { error, _ in
                if let error = error {
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }

                // Update the local friend list in-memory
                self?.currentUserFriends.insert(userID)
                self?.tableView.reloadData()
            }
        }
    }

    private func removeFriend(userID: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        // Remove from current user's friends list in Firebase
        database.child("users").child(currentUserID).child("friends")

            .queryOrderedByValue()
            .queryEqual(toValue: userID)
            .observeSingleEvent(of: .value) { [weak self] snapshot in
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot {
                        snapshot.ref.removeValue()
                    }
                }

                // Remove the current user from the other user's friends list in Firebase
                self?.database.child("users").child(userID).child("friends")
                    .queryOrderedByValue()
                    .queryEqual(toValue: currentUserID)
                    .observeSingleEvent(of: .value) { snapshot in
                        for child in snapshot.children {
                            if let snapshot = child as? DataSnapshot {
                                snapshot.ref.removeValue()
                            }
                        }

                        // Ensure the UI is updated properly
                        self?.updateFilteredUsers()
                    }
            }
    }



    // Ensure that when navigating back, you refresh the list of filtered users (if applicable)
    private func updateFilteredUsers() {
        // Fetch the updated list of friends from Firebase
        fetchCurrentUserFriends()

        // Filter the `filteredUsers` array to include only current friends
        self.filteredUsers = self.filteredUsers.filter { user in
            self.currentUserFriends.contains(user.id)
        }

        // Reload the table view on the main thread
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension AddFriendsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            fetchAllUsers()
        } else {
            searchUsers(with: searchText)
        }
    }
}

// MARK: - UITableViewDelegate
extension AddFriendsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = filteredUsers[indexPath.row]
        let profileVC = FriendProfileViewController(user: user)
        navigationController?.pushViewController(profileVC, animated: true)
    }

}



// MARK: - UITableViewDataSource
extension AddFriendsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = filteredUsers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EnhancedFriendCell", for: indexPath) as! EnhancedFriendCell

        // Determine if the user is a friend
        let isFriend = currentUserFriends.contains(user.id)

        // Configure the cell with both button actions
        cell.configure(with: user, isFriend: isFriend, action: { [weak self] in
            if isFriend {
                self?.removeFriend(userID: user.id)
            } else {
                self?.addFriend(userID: user.id)
            }
        }, viewProfileAction: { [weak self] in
            // Navigate to the user's profile when "View Profile" is tapped
            let profileVC = FriendProfileViewController(user: user)
            self?.navigationController?.pushViewController(profileVC, animated: true)
        })

        return cell
    }
}

class EnhancedFriendCell: UITableViewCell {
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()

    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 2
        return label
    }()

    private let actionButton = UIButton(type: .system) // Add/Remove Friend button
    private let viewProfileButton = UIButton(type: .system) // View Profile button

    var onActionButtonTap: (() -> Void)?
    var onViewProfileButtonTap: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Configure labels
        contentView.addSubview(nameLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(taglineLabel)

        // Configure action button (Add/Remove Friend)
        contentView.addSubview(actionButton)
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        actionButton.layer.cornerRadius = 5
        actionButton.backgroundColor = UIColor(hex: "#7DCF96")
        actionButton.setTitleColor(.white, for: .normal)
        
        // Set content hugging and compression resistance priorities to allow shrinking
        actionButton.setContentHuggingPriority(.required, for: .horizontal)
        actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        // Configure view profile button
        contentView.addSubview(viewProfileButton)
        viewProfileButton.addTarget(self, action: #selector(viewProfileButtonTapped), for: .touchUpInside)
        viewProfileButton.layer.cornerRadius = 5
        viewProfileButton.backgroundColor = UIColor(hex: "#7DCF96")
        viewProfileButton.setTitleColor(.white, for: .normal)
        
        // Set content hugging and compression resistance priorities to allow shrinking
        viewProfileButton.setContentHuggingPriority(.required, for: .horizontal)
        viewProfileButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        // Set up the layout constraints
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        taglineLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        viewProfileButton.translatesAutoresizingMaskIntoConstraints = false

        // Constraints for labels
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),

            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),

//            taglineLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 5),
//            taglineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
//            taglineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
//            taglineLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50), // Keep space for buttons
        ])

        // Constraints for buttons
        NSLayoutConstraint.activate([
            // Action Button Constraints
            actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            actionButton.heightAnchor.constraint(equalToConstant: 28),
            actionButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.45), // 45% of contentView width

            // View Profile Button Constraints
            viewProfileButton.leadingAnchor.constraint(equalTo: actionButton.trailingAnchor, constant: 10), // Small gap between the buttons
            viewProfileButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            viewProfileButton.heightAnchor.constraint(equalToConstant: 28),
            viewProfileButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.45), // 45% of contentView width
            viewProfileButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
    }

    func configure(with user: User, isFriend: Bool, action: @escaping () -> Void, viewProfileAction: @escaping () -> Void) {
        nameLabel.text = user.name
        usernameLabel.text = "@\(user.username)"
        taglineLabel.text = user.tagline

        // Configure Add/Remove Friend button
        actionButton.setTitle(isFriend ? "Remove Friend" : "Add Friend", for: .normal)
        
        // Configure View Profile button
        viewProfileButton.setTitle("View Profile", for: .normal)

        // Set up the closures for button taps
        self.onActionButtonTap = action
        self.onViewProfileButtonTap = viewProfileAction
    }

    @objc private func actionButtonTapped() {
        onActionButtonTap?()
    }

    @objc private func viewProfileButtonTapped() {
        onViewProfileButtonTap?()
    }
}
