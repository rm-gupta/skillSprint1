//
//  LibraryTableViewCell.swift
//  skillSprint
//
//  Created by Heyu Zhou on 11/11/24.
//

import UIKit
protocol LibraryTableViewCellDelegate: AnyObject {
    func playButtonPressed(forCell cell: LibraryTableViewCell)
}

// Custom tabel view cell for the skill library tabel view
class LibraryTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    
    weak var delegate: LibraryTableViewCellDelegate?
    
    @IBOutlet weak var playButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor =  ColorThemeManager.shared.backgroundColor

    }
    
    // WHen play button is pressed, play the current video
    @IBAction func playPressed(_ sender: UIButton) {
        // Notify the delegate when the play button is pressed
        print("button pressed!")
        delegate?.playButtonPressed(forCell: self)
    }
   
}

