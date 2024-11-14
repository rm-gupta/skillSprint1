//
//  HomeScreenViewController.swift
//  skillSprint
//

import UIKit
import FirebaseAuth
import FirebaseFirestore // imported to store data

class HomeScreenViewController: UIViewController {

    @IBOutlet weak var streakLabel: UILabel!
    
    private var dateChangeTimer: Timer?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var diffLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    private let db = Firestore.firestore()
    
    var skillTitle: String?
    var skillDesc: String?
    var skillInstr: String?
    var skillDiff: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        displayCurrentDate()
        loadUserStreakAndScore()
        fetchOneSkill()
        
        // Receive a notification from difficulty preference screen,
        // so that when the difficulty setting is changed, display
        // the skill that is within that difficulty
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateSkillForSelectedDifficulty),
            name: Notification.Name("DifficultyPreferenceChanged"),
            object: nil)
    }
    
    // Sets the dark/ligth theme
    private func applyTheme() {
        view.backgroundColor = ColorThemeManager.shared.backgroundColor
    }
    
    // Set up the timer with a 60-second interval that checks whether the date changed or not
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme()
        dateChangeTimer = Timer.scheduledTimer(
            withTimeInterval: 60,
            repeats: true
        ) { [weak self] _ in
            self?.checkForDateChange()
        }
    }
    
    // Disables the timer when the user leaves the home screen
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            dateChangeTimer?.invalidate()
            dateChangeTimer = nil
    }
    
    // Checks if the data has changed, and update the date on home screen if needed
    func checkForDateChange() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let currentDateString = dateFormatter.string(from: currentDate)

        // Only update if the date has actually changed
        if dateLabel.text != currentDateString {
            displayCurrentDate()
            fetchOneSkill()
        }
    }
    
    // Displays the current date on the home screen
    func displayCurrentDate() {
        let currentDate = Date()

        // Set up the date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale.current

        let dateString = dateFormatter.string(from: currentDate)

        dateLabel.text = dateString
    }
    
    // Refetch a skill that matches the updated difficulty
    @objc func updateSkillForSelectedDifficulty() {
        fetchOneSkill()
    }
    
    // This function fetches one skill from the database according to the current date,
    // and then stores the attributes of the skill that are needed for display
    func fetchOneSkill() {
        db.collection("skills").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }

            // Ensure there's at least one document
            guard let documents = snapshot?.documents, let firstDocument = documents.first else {
                print("No skills found")
                return
            }
            
            let defaults = UserDefaults.standard
            
            // If the user's difficulty preferences are not set, set all to true
            if defaults.value(forKey: "easyPreference") == nil {
                defaults.set(true, forKey: "easyPreference")
                defaults.set(true, forKey: "mediumPreference")
                defaults.set(true, forKey: "hardPreference")
                defaults.set(true, forKey: "anyPreference")
            }
                    
            let easySelected = UserDefaults.standard.bool(forKey: "easyPreference")
            let mediumSelected = UserDefaults.standard.bool(forKey: "mediumPreference")
            let hardSelected = UserDefaults.standard.bool(forKey: "hardPreference")
            
            // Filter the documents to display according to user preferences;
            // The preferences are set up in the settings.
            let filteredDocuments = documents.filter { document in
                let difficulty = document.data()["difficulty"] as? String ?? ""
                return (difficulty == "easy" && easySelected) ||
                        (difficulty == "med" && mediumSelected) ||
                        (difficulty == "hard" && hardSelected)
            }
            
            let totalSkills = filteredDocuments.count
            let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
            let skillIndex = dayOfYear % totalSkills // The home screen displays skill according to day of year

            let document = filteredDocuments[skillIndex]
            let data = document.data()
            
            self.skillTitle = data["title"] as? String ?? "No Title"
            self.skillDesc = data["description"] as? String ?? "No Description"
            self.skillInstr = data["instruction"] as? String ?? "No Instructions"
            self.skillDiff = data["difficulty"] as? String ?? "No Difficulty"

            DispatchQueue.main.async {
                self.titleLabel.text = self.skillTitle
                self.descLabel.text = self.skillDesc
                self.diffLabel.text = self.skillDiff
            }
        }
    }
    
    // when segue triggered, pass revelent information to the
    // skill details screen.
    override func prepare(for segue: UIStoryboardSegue, sender:Any?){
        if segue.identifier == "homeToDetails",
           let detailVC = segue.destination as? SkillDetailViewController{
            detailVC.delegate = self
            detailVC.skillTitle = self.skillTitle
            detailVC.skillDesc = self.skillDesc
            detailVC.skillInstr = self.skillInstr
            detailVC.skillDiff = self.skillDiff
//            print("skillTitle: \(skillTitle ?? "nil")")
//            print("skillDesc: \(skillDesc ?? "nil")")
//            print("skillInstr: \(skillInstr ?? "nil")")
            
        }
    }
    
    // Function to load and display the current user's streak and score
    func loadUserStreakAndScore() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No logged-in user")
            return
        }
        
        let userRef = db.collection("users").document(currentUser.uid)
        
        // Fetch the user's streak and score data from Firestore
        userRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let streak = data?["streak"] as? Int ?? 0
                let score = data?["score"] as? Int ?? 0
                let lastParticipationTimestamp = data?["lastParticipation"] as? Timestamp
                let lastParticipationDate = lastParticipationTimestamp?.dateValue()
                
                // Update the streak and score if necessary based on the last participation date
                self?.updateStreakAndScore(streak: streak, score: score, lastParticipationDate: lastParticipationDate)
            } else {
                // No data exists, so start a new streak and score
                self?.startNewStreakAndScore()
            }
        }
    }
    
    // Function to update streak and score based on the last participation date
    func updateStreakAndScore(streak: Int, score: Int, lastParticipationDate: Date?) {
        let calendar = Calendar.current
        let today = Date()
        
        if let lastDate = lastParticipationDate {
            let daysBetween = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0
            
            if daysBetween == 1 {
                let newStreak = streak + 1
                let newScore = score + 10
                updateFirestoreStreakAndScore(newStreak: newStreak, newScore: newScore)
            } else if daysBetween > 1 {
                // User missed a day, reset streak and add a new score for today
                startNewStreakAndScore()
            } else {
                // User logged in again on the same day, no change to streak or score
                self.streakLabel.text = "Streak: \(streak)"
            }
        } else {
            // First-time participation, start new streak and score
            startNewStreakAndScore()
        }
    }
    
    // Function to start a new streak and set initial score
    func startNewStreakAndScore() {
        updateFirestoreStreakAndScore(newStreak: 1, newScore: 10)
    }
    
    // Function to update Firestore with the new streak and score
    func updateFirestoreStreakAndScore(newStreak: Int, newScore: Int) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No logged-in user")
            return
        }
        
        let userRef = db.collection("users").document(currentUser.uid)
        let today = Date()
        
        let userData: [String: Any] = [
            "streak": newStreak,
            "score": newScore,
            "lastParticipation": Timestamp(date: today)
        ]
        
        userRef.setData(userData, merge: true) { [weak self] error in
            if let error = error {
                print("Error updating streak and score: \(error.localizedDescription)")
            } else {
                print("Streak and score successfully updated: Streak: \(newStreak), Score: \(newScore)")
                DispatchQueue.main.async {
                    self?.streakLabel.text = "Streak: \(newStreak) days"
                }
            }
        }
    }
}


