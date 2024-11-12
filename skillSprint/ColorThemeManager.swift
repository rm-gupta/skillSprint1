import UIKit

enum ColorTheme: String {
    case light, dark

    // Define custom background colors for each theme
    var mainBackgroundColor: UIColor {
        switch self {
        case .light:
            return UIColor(hex: "#FFFef1") // Light background color
        case .dark:
            return UIColor(hex: "#356D6B") // Dark background color
        }
    }

    var mainTextColor: UIColor {
        switch self {
        case .light:
            return UIColor.black // Black text color for light mode
        case .dark:
            return UIColor.white // White text color for dark mode
        }
    }
}

class ColorThemeManager {
    static let shared = ColorThemeManager()
    private init() {}

    private let themeKey = "selectedColorTheme"

    // Current theme with UserDefaults storage
    var currentTheme: ColorTheme {
        get {
            let savedTheme = UserDefaults.standard.string(forKey: themeKey) ?? ColorTheme.light.rawValue
            return ColorTheme(rawValue: savedTheme) ?? .light
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: themeKey)
        }
    }

    // Convenience properties for easier access
    var backgroundColor: UIColor {
        return currentTheme.mainBackgroundColor
    }

    var textColor: UIColor {
        return currentTheme.mainTextColor
    }
}

// Extension for UIColor to support hex color codes
extension UIColor {
    convenience init(hex: String) {
        var hexFormatted: String = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexFormatted = hexFormatted.replacingOccurrences(of: "#", with: "")

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

