import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var visibilitySegmentedControl: UISegmentedControl!

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

    private func applyTheme() {
        view.backgroundColor = ColorThemeManager.shared.backgroundColor
    }
}


