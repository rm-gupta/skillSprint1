import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var darkModeSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the switch based on the current theme saved in ColorThemeManager
        // If the theme is dark, the switch should be on; if light, it should be off.
        darkModeSwitch.isOn = ColorThemeManager.shared.currentTheme == .dark
        applyTheme()
    }

    @IBAction func darkModeSwitchChanged(_ sender: UISwitch) {
        // Update the ColorThemeManager's theme based on the switch state
        ColorThemeManager.shared.currentTheme = sender.isOn ? .dark : .light
        applyTheme()
    }

    private func applyTheme() {
        // Apply the current theme's background color to the settings view
        view.backgroundColor = ColorThemeManager.shared.backgroundColor
        // Update other UI elements as needed, e.g., labels, buttons, etc.
    }
}

