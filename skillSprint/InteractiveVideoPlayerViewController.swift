//
//  InteractiveVideoPlayerViewController.swift
//  skillSprint
//
//  Created by Jeanie Ho on 11/12/24.
//

import UIKit
import AVKit
import FirebaseFirestore
import FirebaseAuth

class InteractiveVideoPlayerViewController: AVPlayerViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UI Components
    private let heartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "message"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let viewCommentsButton: UIButton = {
           let button = UIButton(type: .system)
           button.setImage(UIImage(systemName: "text.bubble"), for: .normal)
           button.tintColor = .black
           button.translatesAutoresizingMaskIntoConstraints = false
           return button
    }()
    
    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Video details
    var videoURL: URL?
    var videoID: String?
    
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInteractionButtons()
        
        fetchVideoLikeDetails()
    }
    
    // Store fetched comments as a property
    private var fetchedComments: [(userName: String, text: String, timestamp: Date)] {
        get {
            objc_getAssociatedObject(self, &commentsAssociatedKey) as? [(userName: String, text: String, timestamp: Date)] ?? []
        }
        set {
            objc_setAssociatedObject(self, &commentsAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // Create an associated object key for storing comments
    private var commentsAssociatedKey: UInt8 = 0
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        
        let comment = fetchedComments[indexPath.row]
        
        // Create a custom cell layout
        let commentLabel = UILabel()
        commentLabel.numberOfLines = 0
        commentLabel.text = "\(comment.userName): \(comment.text)"
        
        let timestampLabel = UILabel()
        timestampLabel.font = UIFont.systemFont(ofSize: 12)
        timestampLabel.textColor = .gray
        
        // Format timestamp
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        timestampLabel.text = formatter.string(from: comment.timestamp)
        
        // Use a vertical stack view for layout
        let stackView = UIStackView(arrangedSubviews: [commentLabel, timestampLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        
        cell.contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8)
        ])
        
        return cell
    }
    
    private func setupInteractionButtons() {
           let buttonContainer = UIView()
           buttonContainer.translatesAutoresizingMaskIntoConstraints = false
           buttonContainer.backgroundColor = .white.withAlphaComponent(0.7)
           buttonContainer.layer.cornerRadius = 10
           
           // Add view comments button to container
           buttonContainer.addSubview(heartButton)
           buttonContainer.addSubview(commentButton)
           buttonContainer.addSubview(likeCountLabel)
           buttonContainer.addSubview(viewCommentsButton)
           
           view.addSubview(buttonContainer)
           
           NSLayoutConstraint.activate([
               buttonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
               buttonContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
               buttonContainer.heightAnchor.constraint(equalToConstant: 50),
               buttonContainer.widthAnchor.constraint(equalToConstant: 200),
               
               heartButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor, constant: 20),
               heartButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
               heartButton.widthAnchor.constraint(equalToConstant: 30),
               heartButton.heightAnchor.constraint(equalToConstant: 30),
               
               likeCountLabel.leadingAnchor.constraint(equalTo: heartButton.trailingAnchor, constant: 10),
               likeCountLabel.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
               
               commentButton.leadingAnchor.constraint(equalTo: likeCountLabel.trailingAnchor, constant: 20),
               commentButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
               commentButton.widthAnchor.constraint(equalToConstant: 30),
               commentButton.heightAnchor.constraint(equalToConstant: 30),
               
               viewCommentsButton.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 20),
               viewCommentsButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
               viewCommentsButton.widthAnchor.constraint(equalToConstant: 30),
               viewCommentsButton.heightAnchor.constraint(equalToConstant: 30)
           ])
           
           heartButton.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)
           commentButton.addTarget(self, action: #selector(commentButtonTapped), for: .touchUpInside)
           viewCommentsButton.addTarget(self, action: #selector(viewCommentsButtonTapped), for: .touchUpInside)
       }
    
    // MARK: - Interaction Handlers
    @objc private func heartButtonTapped() {
        guard let videoID = videoID else { return }
        
        let videoRef = db.collection("videos").document(videoID)
        
        // First, check if the document exists, if not, create it
       videoRef.getDocument { (document, error) in
           if let document = document, !document.exists {
               // Create the initial document with default values
               videoRef.setData([
                   "likes": 0,
                   "likedBy": [],
                   "videoURL": self.videoURL?.absoluteString ?? ""
               ])
           }
           // Toggle like state
           self.heartButton.isSelected.toggle()
           
           if self.heartButton.isSelected {
               // Add like
               videoRef.updateData([
                   "likes": FieldValue.increment(Int64(1)),
                   "likedBy": FieldValue.arrayUnion(["anonymous"])
               ]) { error in
                   if let error = error {
                       print("Error adding like: \(error)")
                       self.heartButton.isSelected.toggle()
                   } else {
                       self.updateLikeCount()
                   }
               }
           } else {
               // Remove like
               videoRef.updateData([
                   "likes": FieldValue.increment(Int64(-1)),
                   "likedBy": FieldValue.arrayRemove(["anonymous"])
               ]) { error in
                   if let error = error {
                       print("Error removing like: \(error)")
                       self.heartButton.isSelected.toggle()
                   } else {
                       self.updateLikeCount()
                   }
               }
           }
       }
    }

    @objc private func commentButtonTapped() {
        guard let videoID = videoID else { return }
        
        // Present a comment alert
        let commentAlert = UIAlertController(title: "Add Comment", message: nil, preferredStyle: .alert)
        commentAlert.addTextField { textField in
            textField.placeholder = "Your name (optional)"
        }
        commentAlert.addTextField { textField in
            textField.placeholder = "Write a comment..."
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            guard let nameField = commentAlert.textFields?[0],
                  let commentField = commentAlert.textFields?[1],
                  let comment = commentField.text,
                  !comment.isEmpty else { return }
            
            let userName = nameField.text?.isEmpty == false ? nameField.text! : "Anonymous"
            
            // Save comment to Firestore
            let commentData: [String: Any] = [
                "text": comment,
                "userName": userName,
                "timestamp": FieldValue.serverTimestamp()
            ]
            
            self?.db.collection("videos").document(videoID).collection("comments").addDocument(data: commentData)
        }
        
        commentAlert.addAction(submitAction)
        commentAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(commentAlert, animated: true)
    }
    
    @objc private func viewCommentsButtonTapped() {
        guard let videoID = videoID else { return }
        
        // Create a view controller to display comments
        let commentsViewController = UIViewController()
        commentsViewController.view.backgroundColor = .white
        commentsViewController.title = "Comments"
        
        // Create a table view to show comments
        let tableView = UITableView(frame: commentsViewController.view.bounds, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommentCell")
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        commentsViewController.view.addSubview(tableView)
        
        // Create a custom view controller for comments
        class CommentsTableViewController: UITableViewController {
            var comments: [(userName: String, text: String, timestamp: Date)] = []
            let db = Firestore.firestore()
            let videoID: String
            
            init(videoID: String) {
                self.videoID = videoID
                super.init(style: .plain)
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func viewDidLoad() {
                super.viewDidLoad()
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommentCell")
                fetchComments()
            }
            
            func fetchComments() {
                db.collection("videos").document(videoID).collection("comments")
                    .order(by: "timestamp", descending: true)
                    .getDocuments { [weak self] (querySnapshot, error) in
                        if let error = error {
                            print("Error fetching comments: \(error)")
                            return
                        }
                        
                        // Clear existing comments
                        self?.comments.removeAll()
                        
                        // Process fetched comments
                        querySnapshot?.documents.forEach { document in
                            let data = document.data()
                            if let userName = data["userName"] as? String,
                               let text = data["text"] as? String,
                               let timestamp = data["timestamp"] as? Timestamp {
                                self?.comments.append((userName: userName, text: text, timestamp: timestamp.dateValue()))
                            }
                        }
                        
                        // Reload table view on main thread
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    }
            }
            
            override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return comments.count
            }
            
            override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
                
                let comment = comments[indexPath.row]
                
                // Create a custom cell layout
                let commentLabel = UILabel()
                commentLabel.numberOfLines = 0
                commentLabel.text = "\(comment.userName): \(comment.text)"
                
                let timestampLabel = UILabel()
                timestampLabel.font = UIFont.systemFont(ofSize: 12)
                timestampLabel.textColor = .gray
                
                // Format timestamp
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                timestampLabel.text = formatter.string(from: comment.timestamp)
                
                // Use a vertical stack view for layout
                let stackView = UIStackView(arrangedSubviews: [commentLabel, timestampLabel])
                stackView.axis = .vertical
                stackView.spacing = 4
                
                cell.contentView.addSubview(stackView)
                stackView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    stackView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
                    stackView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                    stackView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                    stackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8)
                ])
                
                return cell
            }
        }
        
        // Create and present the comments table view controller
        let commentsTableVC = CommentsTableViewController(videoID: videoID)
        let navController = UINavigationController(rootViewController: commentsTableVC)
        present(navController, animated: true)
    }
    
    // Fetch initial like details
    private func fetchVideoLikeDetails() {
        guard let videoID = videoID else { return }
        
        let videoRef = db.collection("videos").document(videoID)
        
        videoRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists,
               let data = document.data(),
               let likes = data["likes"] as? Int,
               let likedBy = data["likedBy"] as? [String] {
                
                DispatchQueue.main.async {
                    self?.likeCountLabel.text = "\(likes)"
                    
                    // Check if current user has already liked
                    if let currentUser = Auth.auth().currentUser,
                       likedBy.contains(currentUser.uid) {
                        self?.heartButton.isSelected = true
                    }
                }
            }
        }
    }
    
    // Update like count display
    private func updateLikeCount() {
        guard let videoID = videoID else { return }
        
        let videoRef = db.collection("videos").document(videoID)
        videoRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists,
               let data = document.data(),
               let likes = data["likes"] as? Int {
                
                DispatchQueue.main.async {
                    self?.likeCountLabel.text = "\(likes)"
                }
            }
        }
    }
}
