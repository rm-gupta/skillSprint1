import UIKit
import FirebaseFirestore
import FirebaseAuth

class SkillInsightsViewController: UIViewController {
    // Firestore reference
    let db = Firestore.firestore()
    
    // IBOutlet connections
    @IBOutlet weak var skillStreakLabel: UILabel!
    @IBOutlet weak var totalSkillsLabel: UILabel!
    @IBOutlet weak var easySkillsLabel: UILabel!
    @IBOutlet weak var mediumSkillsLabel: UILabel!
    @IBOutlet weak var hardSkillsLabel: UILabel!
    @IBOutlet weak var mostVisitedSkillLabel: UILabel!
    @IBOutlet weak var barGraphView: UIView! // The white UIView for the bar graph
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSkillData()
        loadUserStreakAndScore()
    }
    
    private func fetchSkillData() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }
        
        // Fetch skills from the user's collection
        db.collection("users").document(userID).collection("skills").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching user skills: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents in user's skills collection.")
                self.updateUIWithZeroSkills()
                return
            }
            
            if documents.isEmpty {
                self.updateUIWithZeroSkills()
                return
            }
            
            // Count skills by difficulty
            var easyCount = 0
            var mediumCount = 0
            var hardCount = 0
            var mostVisitedSkill: String = "No Skills Have Been Completed Yet!"
            var maxVisits = 0
            
            for document in documents {
                let data = document.data()
                let difficulty = data["difficulty"] as? String ?? ""
                let visits = data["visits"] as? Int ?? 0
                let title = data["title"] as? String ?? ""
                
                switch difficulty.lowercased() {
                case "easy":
                    easyCount += 1
                case "medium":
                    mediumCount += 1
                case "hard":
                    hardCount += 1
                default:
                    break
                }
                
                if visits > maxVisits {
                    maxVisits = visits
                    mostVisitedSkill = title
                }
            }
            
            // Update UI labels
            DispatchQueue.main.async {
                self.easySkillsLabel.text = "\(easyCount)"
                self.mediumSkillsLabel.text = "\(mediumCount)"
                self.hardSkillsLabel.text = "\(hardCount)"
                self.totalSkillsLabel.text = "\(easyCount + mediumCount + hardCount)"
                self.mostVisitedSkillLabel.text = mostVisitedSkill
                
                // Render the bar graph
                self.renderBarGraph(easy: easyCount, medium: mediumCount, hard: hardCount)
            }
        }
    }
    
    private func updateUIWithZeroSkills() {
        DispatchQueue.main.async {
            self.easySkillsLabel.text = "0"
            self.mediumSkillsLabel.text = "0"
            self.hardSkillsLabel.text = "0"
            self.totalSkillsLabel.text = "0"
            self.mostVisitedSkillLabel.text = "No skills completed yet!"
            self.renderBarGraph(easy: 0, medium: 0, hard: 0)
        }
    }
    
    private func renderBarGraph(easy: Int, medium: Int, hard: Int) {
        // Clear any existing bars or labels in the view
        barGraphView.subviews.forEach { $0.removeFromSuperview() }
        
        let totalSkills = easy + medium + hard
        let maxBarHeight = barGraphView.frame.height * 0.8 // Reserve space for labels
        let barWidth: CGFloat = barGraphView.frame.width / 5 // 3 bars + 2 gaps
        let yAxisMargin: CGFloat = 30 // Margin for y-axis
        
        // Add Y-axis labels (e.g., 0, 5, 10)
        let yAxisSteps = [0, 5, 10]
        for step in yAxisSteps {
            let yPosition = maxBarHeight - CGFloat(step) / 10.0 * maxBarHeight
            let label = UILabel(frame: CGRect(x: 0, y: yPosition - 10, width: yAxisMargin, height: 20))
            label.text = "\(step)"
            label.font = UIFont.systemFont(ofSize: 12)
            label.textAlignment = .right
            barGraphView.addSubview(label)
        }
        
        // Calculate bar heights (default to small line if no skills)
        let easyBarHeight = totalSkills > 0 ? CGFloat(easy) / 10.0 * maxBarHeight : 2
        let mediumBarHeight = totalSkills > 0 ? CGFloat(medium) / 10.0 * maxBarHeight : 2
        let hardBarHeight = totalSkills > 0 ? CGFloat(hard) / 10.0 * maxBarHeight : 2
        
        // Easy Bar
        let easyBar = UIView(frame: CGRect(
            x: yAxisMargin + barWidth * 0.5,
            y: maxBarHeight - easyBarHeight,
            width: barWidth,
            height: easyBarHeight
        ))
        easyBar.backgroundColor = .green
        barGraphView.addSubview(easyBar)
        
        // Easy Label
        let easyLabel = UILabel(frame: CGRect(
            x: yAxisMargin + barWidth * 0.5,
            y: maxBarHeight + 5,
            width: barWidth,
            height: 20
        ))
        easyLabel.text = "Easy: \(easy)"
        easyLabel.textAlignment = .center
        easyLabel.font = UIFont.systemFont(ofSize: 12)
        barGraphView.addSubview(easyLabel)
        
        // Medium Bar
        let mediumBar = UIView(frame: CGRect(
            x: yAxisMargin + barWidth * 2,
            y: maxBarHeight - mediumBarHeight,
            width: barWidth,
            height: mediumBarHeight
        ))
        mediumBar.backgroundColor = .blue
        barGraphView.addSubview(mediumBar)
        
        // Medium Label
        let mediumLabel = UILabel(frame: CGRect(
            x: yAxisMargin + barWidth * 2,
            y: maxBarHeight + 5,
            width: barWidth,
            height: 20
        ))
        mediumLabel.text = "Med: \(medium)"
        mediumLabel.textAlignment = .center
        mediumLabel.font = UIFont.systemFont(ofSize: 12)
        barGraphView.addSubview(mediumLabel)
        
        // Hard Bar
        let hardBar = UIView(frame: CGRect(
            x: yAxisMargin + barWidth * 3.5,
            y: maxBarHeight - hardBarHeight,
            width: barWidth,
            height: hardBarHeight
        ))
        hardBar.backgroundColor = .red
        barGraphView.addSubview(hardBar)
        
        // Hard Label
        let hardLabel = UILabel(frame: CGRect(
            x: yAxisMargin + barWidth * 3.5,
            y: maxBarHeight + 5,
            width: barWidth,
            height: 20
        ))
        hardLabel.text = "Hard: \(hard)"
        hardLabel.textAlignment = .center
        hardLabel.font = UIFont.systemFont(ofSize: 12)
        barGraphView.addSubview(hardLabel)
        
        // Add base line to indicate 0 progress
        let baseLine = UIView(frame: CGRect(
            x: yAxisMargin,
            y: maxBarHeight,
            width: barGraphView.frame.width - yAxisMargin,
            height: 1
        ))
        baseLine.backgroundColor = .lightGray
        barGraphView.addSubview(baseLine)
    }

       

    
    // Streak Logic from HomeScreenViewController
    func loadUserStreakAndScore() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No logged-in user")
            return
        }
        
        let userRef = db.collection("users").document(currentUser.uid)
        
        // Fetch the user's streak data from Firestore
        userRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let document = document, document.exists {
                let data = document.data()
                let streak = data?["streak"] as? Int ?? 0
                let lastParticipationTimestamp = data?["lastParticipation"] as? Timestamp
                let lastParticipationDate = lastParticipationTimestamp?.dateValue()
                
                // Update the streak label based on the last participation date
                DispatchQueue.main.async {
                    if let lastDate = lastParticipationDate,
                       Calendar.current.isDateInToday(lastDate) {
                        self.skillStreakLabel.text = "\(streak) days"
                    } else {
                        self.skillStreakLabel.text = "0 days"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.skillStreakLabel.text = "0 days"
                }
            }
        }
    }
}

