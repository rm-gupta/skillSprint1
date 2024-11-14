import UIKit
import FirebaseAuth
import FirebaseDatabase

class BadgesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var achievedBadges: [Badge] = []
    private var friendIDs: Set<String> = []
    private let database = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BadgeManager.shared.addTestBadge()
        
        // Load badges based on visibility setting
        fetchCurrentUserFriends { [weak self] in
            self?.loadBadgesBasedOnVisibility()
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func loadBadgesBasedOnVisibility() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        // Get badges based on the visibility setting in BadgeManager
        achievedBadges = BadgeManager.shared.getVisibleBadges(for: currentUserID, friendIDs: friendIDs)
        
        collectionView.reloadData()
    }
    
    // Fetch the user's friends and store their IDs in friendIDs
    private func fetchCurrentUserFriends(completion: @escaping () -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        database.child("users").child(currentUserID).child("friends").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            self.friendIDs.removeAll()
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let friendID = snapshot.value as? String {
                    self.friendIDs.insert(friendID)
                }
            }
            
            completion() // Call completion to load badges after fetching friends
        }
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
    
    private func applyTheme() {
        view.backgroundColor = ColorThemeManager.shared.backgroundColor
    }
}

