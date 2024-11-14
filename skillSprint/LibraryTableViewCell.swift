//
//  LibraryTableViewCell.swift
//  skillSprint
//
//  Created by Heyu Zhou on 11/11/24.
//

import UIKit

// Custom tabel view cell for the skill library tabel view
class LibraryTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor =  ColorThemeManager.shared.backgroundColor
    }
    // This is not linked yet
    @IBAction func playPressed(_ sender: UIButton) {
        
    }
}

