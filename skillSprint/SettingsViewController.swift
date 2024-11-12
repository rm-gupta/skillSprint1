import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
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
