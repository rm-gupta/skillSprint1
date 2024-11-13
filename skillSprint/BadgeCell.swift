//
//  BadgeCell.swift
//  skillSprint
//
//  Created by Jeanie Ho on 11/04/24.
//

import UIKit

class BadgeCell: UICollectionViewCell {
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var badgeLabel: UILabel!
    
    func configure(with badge: Badge) {
        badgeImageView.image = UIImage(named: badge.iconName)
        badgeLabel.text = badge.name
        badgeImageView.alpha = badge.isAchieved ? 1.0 : 0.3
    }
}
