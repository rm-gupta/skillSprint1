//
//  LibraryTableViewCell.swift
//  skillSprint
//
//  Created by Heyu Zhou on 11/11/24.
//

import UIKit

class LibraryTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    
    // This is not linked!!!
    @IBAction func playPressed(_ sender: UIButton) {
        
    }
}

