//
//  HomeScreenViewController.swift
//  skillSprint
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeScreenViewController: UIViewController {

    @IBOutlet weak var streakLabel: UILabel!
    
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load user streak and score when the view loads
        loadUserStreakAndScore()
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


