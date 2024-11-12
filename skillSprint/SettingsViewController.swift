import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var darkModeSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set switch based on the current theme
        darkModeSwitch.isOn = ColorThemeManager.shared.currentTheme == .dark
        applyTheme()
    }

    @IBAction func darkModeSwitchChanged(_ sender: UISwitch) {
        // Update the ColorThemeManager's theme based on the switch state
        ColorThemeManager.shared.currentTheme = sender.isOn ? .dark : .light
        applyTheme()
    }

    private func applyTheme() {
        view.backgroundColor = ColorThemeManager.shared.backgroundColor
    }
}
