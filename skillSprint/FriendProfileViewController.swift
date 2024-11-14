//
//  FriendProfileViewController.swift
//  skillSprint
//
//  Created by Ritu Gupta on 11/13/24.
//

import UIKit
import FirebaseDatabase

class FriendProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var friendProfPhoto: UIImageView!
    
    var username: String? // This property will store the username passed from AddFriendsViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let username = username {
            fetchUserData(username: username)
        }
    }
    
    func fetchUserData(username: String) {
        let ref = Database.database().reference()

        ref.child("users").queryOrdered(byChild: "username").queryEqual(toValue: username).observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? [String: Any] {
                for (key, data) in value {
                    if let userData = data as? [String: Any] {
                        let username = userData["username"] as? String ?? "No username"
                        let tagline = userData["tagline"] as? String ?? "No tagline"
                        let name = userData["name"] as? String ?? "No name"
                        
                        DispatchQueue.main.async {
                            self.usernameLabel.text = username
                            self.taglineLabel.text = tagline
                            self.nameLabel.text = name
                        }
                    }
                }
            }
        }) { error in
            print("Error: \(error.localizedDescription)")
        }
    }

}
