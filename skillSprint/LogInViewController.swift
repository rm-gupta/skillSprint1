//
//  LogInViewController.swift
//  skillSprint
//
//

import UIKit
import FirebaseAuth

class LogInViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            errorMessage.text = "Please enter both email and password."
            return
        }

        // Set the shared username before creating the account
        SharedData.shared.username = email
        
        // Attempt to log the user in
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error as NSError? {
                // Display error message if login fails
                self.errorMessage.text = "\(error.localizedDescription)"
            } else {
                // Clear error message and proceed to the home screen on successful login
                self.errorMessage.text = ""
                self.goToHomeScreen()
            }
        }
    }
    
    @IBAction func createAccountButtonPressed(_ sender: Any) {
    }
    
    func goToHomeScreen() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeScreenViewController") as? HomeScreenViewController {
                // Push the HomeScreenViewController onto the navigation stack
                self.navigationController?.pushViewController(homeVC, animated: true)
            }
        }
}

