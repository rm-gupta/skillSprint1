//
//  CreateAccountViewController.swift
//  skillSprint
//
//  Created by Divya Nitin on 10/22/24.
//

import UIKit
import FirebaseAuth

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
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

