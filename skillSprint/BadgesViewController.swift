//
//  BadgesViewController.swift
//  skillSprint
//
//  Created by Jeanie Ho on 11/04/24.
//

import UIKit

class BadgesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var achievedBadges: [Badge] = []
    private var unachievedBadges: [Badge] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // uncomment the line below to see test badges
//        BadgeManager.shared.addTestBadge()
        
        achievedBadges = BadgeManager.shared.achievedBadges()
        unachievedBadges = BadgeManager.shared.unachievedBadges()
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // UICollectionView DataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return achievedBadges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BadgeCell", for: indexPath) as! BadgeCell
        let badge = achievedBadges[indexPath.item]
        cell.configure(with: badge)
        return cell
    }
    
    // UICollectionViewDelegateFlowLayout for 2-column layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize / 2, height: collectionViewSize / 2)
    }
}
