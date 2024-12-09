//
//  CreateAccountViewController.swift
//  skillSprint
//
//  Created by Divya Nitin on 10/22/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func initializeUserData(userId: String, email: String) {
        let ref = Database.database().reference().child("users").child(userId)
           let timestamp = Int(Date().timeIntervalSince1970 * 1000)
           
           // Default user data
           let userData: [String: Any] = [
               "email": email,
               "name": "New User", // Default name
               "tagline": "Excited to join!", // Default tagline
               "friends": [:], // Empty friends dictionary
               "username": email.components(separatedBy: "@").first ?? email, // Default username
               "createdAt": timestamp, // Timestamp for user creation
               "lastUpdated": timestamp // Timestamp for last update
           ]
           
           // Save the default data to the Realtime Database
           ref.setValue(userData) { error, _ in
               if let error = error {
                   print("Error initializing user data: \(error.localizedDescription)")
               } else {
                   print("User data initialized successfully for userId: \(userId)")
               }
           }
    }

    @IBAction func createAccountButtonPressed(_ sender: Any) {
        guard let email = emailField.text, !email.isEmpty,
                 let password = passwordField.text, !password.isEmpty else {
               errorMessage.text = "Please enter email and password."
               return
           }
           
           // Set the shared username before creating the account
           SharedData.shared.username = email
           
           // Create new user in Firebase
           Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
               if let error = error as NSError? {
                   self.errorMessage.text = "\(error.localizedDescription)"
               } else {
                   self.errorMessage.text = ""
                   
                   // Initialize user data in the Realtime Database
                   if let userId = authResult?.user.uid {
                       self.initializeUserData(userId: userId, email: email)
                   }
                   
                   // Automatically log in the user after account creation
                   self.loginAfterAccountCreation(email: email, password: password)
               }
           }
    }
    
    

    func loginAfterAccountCreation(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error as NSError? {
                self.errorMessage.text = "\(error.localizedDescription)"
            } else {
                self.errorMessage.text = ""
                self.goToHomeScreen()
            }
        }
    }
    
    func goToHomeScreen() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeScreenViewController") as? HomeScreenViewController {
                // Push the HomeScreenViewController onto the navigation stack
                self.navigationController?.pushViewController(homeVC, animated: true)
            }
        }
}

