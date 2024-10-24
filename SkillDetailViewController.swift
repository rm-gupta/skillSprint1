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
    
    var skillTitle: String?
    var skillDesc: String?
    var skillInstr: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = skillTitle
        descLabel.text = skillDesc
        let formattedInstructions = skillInstr!.replacingOccurrences(of: "(\\d+\\.)", with: "\n$1", options: .regularExpression)

        // Print the formatted instructions to debug if it's correct
        print(formattedInstructions)

        // Set the formatted text in the UITextView
        instrLabel.text = formattedInstructions
        
    }

}

