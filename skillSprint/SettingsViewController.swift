import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var visibilitySegmentedControl: UISegmentedControl!
    @IBOutlet weak var logoutButton: UIButton! // Connect this button in the storyboard

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the switch based on the current theme saved in ColorThemeManager
        darkModeSwitch.isOn = ColorThemeManager.shared.currentTheme == .dark
        applyTheme()

        // Set the segmented control based on saved visibility setting
        let savedVisibility = BadgeManager.shared.visibility
        visibilitySegmentedControl.selectedSegmentIndex = savedVisibility.rawValue
    }

    @IBAction func darkModeSwitchChanged(_ sender: UISwitch) {
        // Update the ColorThemeManager's theme based on the switch state
        ColorThemeManager.shared.currentTheme = sender.isOn ? .dark : .light
        applyTheme()
    }

    @IBAction func visibilitySegmentChanged(_ sender: UISegmentedControl) {
        // Update BadgeManager's visibility based on the selected segment
        let selectedVisibility = BadgeVisibility(rawValue: sender.selectedSegmentIndex) ?? .justMe
        BadgeManager.shared.visibility = selectedVisibility
    }

    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        do {
                try Auth.auth().signOut()
                
                if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate,
                   let window = sceneDelegate.window {
                    
                    // Instantiate the login view controller
                    let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LogInViewController")
                    
                    // Wrap login view controller in a navigation controller (if using a navigation stack)
                    let navigationController = UINavigationController(rootViewController: loginViewController!)
                    window.rootViewController = navigationController
                    window.makeKeyAndVisible()
                    
                    // Optional transition animation
                    UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
                }
                
            } catch let signOutError as NSError {
                print("Error signing out: \(signOutError.localizedDescription)")
            }
    }

    private func applyTheme() {
        view.backgroundColor = ColorThemeManager.shared.backgroundColor
    }
}

