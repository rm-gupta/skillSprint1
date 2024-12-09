//  SkillDetailViewController.swift
//  skillSprint
//
//  Created by Heyu Zhou on 10/23/24.
//

import UIKit

class SkillDetailViewController: UIViewController {
    
    var delegate:UIViewController!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var instrLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    // Data sttributes of the skill
    var skillTitle: String?
    var skillDesc: String?
    var skillInstr: String?
    var skillDiff: String?
    var skillID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        titleLabel.text = skillTitle
        descLabel.text = skillDesc
        
        // Breaks the skill instructions into separate lines
        let formattedInstructions = skillInstr!.replacingOccurrences(of: "(\\d+\\.)", with: "\n$1", options: .regularExpression)

        // Set the formatted text in the UITextView
        instrLabel.text = formattedInstructions
        
    }
    
    // Re-apply theme every time the view appears
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            applyTheme()
        }
    
    private func applyTheme() {
        view.backgroundColor = ColorThemeManager.shared.backgroundColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toVideoUploadVC" {
            if let videoUploadVC = segue.destination as? VideoUploadViewController {
                videoUploadVC.selectedSkillID = skillID // Pass the skill ID to VideoUploadViewController
            }
        }
    }

}

