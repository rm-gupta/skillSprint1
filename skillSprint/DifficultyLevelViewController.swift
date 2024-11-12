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
        setDefaultDifficultyPreferences()
        loadUserDifficultyPreferences()
    }
    
    func setDefaultDifficultyPreferences() {
        let defaults = UserDefaults.standard
        if defaults.value(forKey: "easyPreference") == nil {
            defaults.set(true, forKey: "easyPreference")
            defaults.set(true, forKey: "mediumPreference")
            defaults.set(true, forKey: "hardPreference")
            defaults.set(true, forKey: "anyPreference")
        }
      }
    
    func loadUserDifficultyPreferences() {
        // Load saved difficulty preferences, e.g., from UserDefaults or Firestore
        // Here we’re assuming you save preferences as Booleans in UserDefaults
        easySwitch.isOn = UserDefaults.standard.bool(forKey: "easyPreference")
        mediumSwitch.isOn = UserDefaults.standard.bool(forKey: "mediumPreference")
        hardSwitch.isOn = UserDefaults.standard.bool(forKey: "hardPreference")
        anySwitch.isOn = easySwitch.isOn && mediumSwitch.isOn && hardSwitch.isOn
    }
    
    @IBAction func easySwitchChanged(_ sender: UISwitch) {
        updateAnySwitch()
    }
        
    @IBAction func mediumSwitchChanged(_ sender: UISwitch) {
        updateAnySwitch()
    }
        
    @IBAction func hardSwitchChanged(_ sender: UISwitch) {
        updateAnySwitch()
    }
        
    @IBAction func anySwitchChanged(_ sender: UISwitch) {
        if anySwitch.isOn {
            easySwitch.isOn = true
            mediumSwitch.isOn = true
            hardSwitch.isOn = true
        }
    }
    
    func updateAnySwitch() {
        if !easySwitch.isOn || !mediumSwitch.isOn || !hardSwitch.isOn {
            anySwitch.isOn = false
        } else {
            anySwitch.isOn = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveUserDifficultyPreferences()
    }
    
    func saveUserDifficultyPreferences() {
        // Save difficulty preferences
        UserDefaults.standard.set(easySwitch.isOn, forKey: "easyPreference")
        UserDefaults.standard.set(mediumSwitch.isOn, forKey: "mediumPreference")
        UserDefaults.standard.set(hardSwitch.isOn, forKey: "hardPreference")
        UserDefaults.standard.set(anySwitch.isOn, forKey: "anyPreference")
        print("easy: \(easySwitch.isOn), med: \(mediumSwitch.isOn), hard: \(hardSwitch.isOn), any: \(anySwitch.isOn)")
//        NotificationCenter.default.post(name: Notification.Name("DifficultyPreferenceChanged"), object: nil)
    }
        

}
