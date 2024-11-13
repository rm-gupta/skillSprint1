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
        displayCurrentDate()
        loadUserStreakAndScore()
        fetchOneSkill()
                
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateSkillForSelectedDifficulty),
            name: Notification.Name("DifficultyPreferenceChanged"),
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set up the timer with a 60-second interval
        dateChangeTimer = Timer.scheduledTimer(
            withTimeInterval: 60,
            repeats: true
        ) { [weak self] _ in
            self?.checkForDateChange()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            dateChangeTimer?.invalidate()
            dateChangeTimer = nil
    }
    
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
    
    func displayCurrentDate() {
        // Get the current date
        let currentDate = Date()

        // Set up the date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium // Use .short, .medium, .long, or .full as needed
        dateFormatter.timeStyle = .none // Adjust if you also want to display time
        dateFormatter.locale = Locale.current // Optional: sets the locale to current region

        // Format the date as a string
        let dateString = dateFormatter.string(from: currentDate)

        // Display the date string in the label
        dateLabel.text = dateString
    }
    
    // Refetch a skill that matches the updated difficulty
    @objc func updateSkillForSelectedDifficulty() {
        fetchOneSkill()
    }
    
    // This function fetches one skill from the database according to the current date and stores the
    // attributes title, description, and instruction of the skill.
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
            
            let easySelected = UserDefaults.standard.bool(forKey: "easyPreference")
            let mediumSelected = UserDefaults.standard.bool(forKey: "mediumPreference")
            let hardSelected = UserDefaults.standard.bool(forKey: "hardPreference")
            
            let filteredDocuments = documents.filter { document in
                let difficulty = document.data()["difficulty"] as? String ?? ""
                return (difficulty == "easy" && easySelected) ||
                        (difficulty == "med" && mediumSelected) ||
                        (difficulty == "hard" && hardSelected)
            }
            // print("easy: \(easySelected), med: \(mediumSelected), hard: \(hardSelected)")
            // Calculate a daily index based on the day of the year
            let totalSkills = filteredDocuments.count
            let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
            let skillIndex = dayOfYear % totalSkills

            // Get the skill for today using the calculated index
            let document = filteredDocuments[skillIndex]
            let data = document.data()
            self.skillTitle = data["title"] as? String ?? "No Title"
            self.skillDesc = data["description"] as? String ?? "No Description"
            self.skillInstr = data["instruction"] as? String ?? "No Instructions"
            self.skillDiff = data["difficulty"] as? String ?? "No Difficulty"

            // Update the UI on the main thread
            DispatchQueue.main.async {
                self.titleLabel.text = self.skillTitle
                self.descLabel.text = self.skillDesc
                self.diffLabel.text = self.skillDiff
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender:Any?){
        // when segue triggered, pass revelent information to the
        // skill details screen.
        if segue.identifier == "homeToDetails",
           let detailVC = segue.destination as? SkillDetailViewController{
            detailVC.delegate = self
            detailVC.skillTitle = self.skillTitle
            detailVC.skillDesc = self.skillDesc
            detailVC.skillInstr = self.skillInstr
            detailVC.skillDiff = self.skillDiff
            print("skillTitle: \(skillTitle ?? "nil")")
            print("skillDesc: \(skillDesc ?? "nil")")
            print("skillInstr: \(skillInstr ?? "nil")")
            
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


