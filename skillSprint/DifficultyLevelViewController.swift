//
//  DifficultyLevelViewController.swift
//  skillSprint
//
//  Created by Heyu Zhou on 11/12/24.
//

import UIKit

class DifficultyLevelViewController: UIViewController {
    @IBOutlet weak var easySwitch: UISwitch!
    @IBOutlet weak var mediumSwitch: UISwitch!
    @IBOutlet weak var hardSwitch: UISwitch!
    @IBOutlet weak var anySwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        setDefaultDifficultyPreferences()
        loadUserDifficultyPreferences()
    }
    
    // Re-apply theme every time the view appears
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            applyTheme()
        }
    
    // if the user preferences has not been set yet, assume all difficulties are displayed
    func setDefaultDifficultyPreferences() {
        let defaults = UserDefaults.standard
        if defaults.value(forKey: "easyPreference") == nil {
            defaults.set(true, forKey: "easyPreference")
            defaults.set(true, forKey: "mediumPreference")
            defaults.set(true, forKey: "hardPreference")
            defaults.set(true, forKey: "anyPreference")
        }
      }
    
    // Load saved difficulty preferences, from UserDefaults
    func loadUserDifficultyPreferences() {
        easySwitch.isOn = UserDefaults.standard.bool(forKey: "easyPreference")
        mediumSwitch.isOn = UserDefaults.standard.bool(forKey: "mediumPreference")
        hardSwitch.isOn = UserDefaults.standard.bool(forKey: "hardPreference")
        anySwitch.isOn = easySwitch.isOn && mediumSwitch.isOn && hardSwitch.isOn
    }
    
    // Update the other switches if necessary when easy switch is toggled
    @IBAction func easySwitchChanged(_ sender: UISwitch) {
        updateAnySwitch()
    }
    
    // Update the other switches if necessary when medium switch is toggled
    @IBAction func mediumSwitchChanged(_ sender: UISwitch) {
        updateAnySwitch()
    }
    
    // Update the other switches if necessary when hard switch is toggled
    @IBAction func hardSwitchChanged(_ sender: UISwitch) {
        updateAnySwitch()
    }
    
    // Update the other switches if necessary when any switch is toggled
    // Basically when any is turned on, all the other switches should be on
    @IBAction func anySwitchChanged(_ sender: UISwitch) {
        if anySwitch.isOn {
            easySwitch.isOn = true
            mediumSwitch.isOn = true
            hardSwitch.isOn = true
        }
    }
    
    // If any switch is turned off, turn the any preference off
    func updateAnySwitch() {
        if !easySwitch.isOn || !mediumSwitch.isOn || !hardSwitch.isOn {
            anySwitch.isOn = false
        } else {
            anySwitch.isOn = true
        }
    }
    
    // When user leaves the screen, save the preferences
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveUserDifficultyPreferences()
    }
    
    // Saves the user preferences of difficulty levels
    func saveUserDifficultyPreferences() {
        UserDefaults.standard.set(easySwitch.isOn, forKey: "easyPreference")
        UserDefaults.standard.set(mediumSwitch.isOn, forKey: "mediumPreference")
        UserDefaults.standard.set(hardSwitch.isOn, forKey: "hardPreference")
        UserDefaults.standard.set(anySwitch.isOn, forKey: "anyPreference")
        // Notifiy the home screen so that a skill that corresponds to the
        // user's preferred difficulty shows up
        NotificationCenter.default.post(name: Notification.Name("DifficultyPreferenceChanged"), object: nil)
    }

    private func applyTheme() {
        view.backgroundColor = ColorThemeManager.shared.backgroundColor
    }
        

}
