//
//  BadgeManager.swift
//  skillSprint
//
//  Created by Jeanie Ho on 11/04/24.
//

import Foundation

// Badge class
struct Badge {
    let name: String
    let description: String
    let iconName: String
    var isAchieved: Bool
}

enum BadgeVisibility: Int {
    case justMe = 0
    case friends = 1
    case everyone = 2
}

class BadgeManager {
    static let shared = BadgeManager()
    
    var badges: [Badge] = [
        Badge(name: "First Steps", description: "Upload your first video", iconName: "badge_1", isAchieved: false),
        Badge(name: "Milestone 25", description: "Upload 25 videos", iconName: "badge_2", isAchieved: false),
        Badge(name: "Second is Best", description: "Upload 2 videos", iconName: "badge_3", isAchieved: false),
        Badge(name: "Milestone 10", description: "Upload 10 videos", iconName: "badge_4", isAchieved: false),
        Badge(name: "Milestone 50", description: "Upload 50 videos", iconName: "badge_5", isAchieved: false),
        Badge(name: "You're Poppin", description: "Upload 5 videos", iconName: "badge_6", isAchieved: false)
    ]
    
    // Store visibility preference
    private let visibilityKey = "badgeVisibility"
    var visibility: BadgeVisibility {
        get {
            let savedValue = UserDefaults.standard.integer(forKey: visibilityKey)
            return BadgeVisibility(rawValue: savedValue) ?? .justMe
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: visibilityKey)
        }
    }
    
    func addTestBadge() {
        let testBadge = Badge(name: "Test Badge", description: "This is a test badge", iconName: "badge_1", isAchieved: true)
        let testBadge2 = Badge(name: "Test 2", description: "This is a test badge", iconName: "badge_1", isAchieved: true)
        let testBadge3 = Badge(name: "Test 3", description: "This is a test badge", iconName: "badge_1", isAchieved: true)
        badges.append(testBadge)
        badges.append(testBadge2)
        badges.append(testBadge3)
    }

    // Badge progress tracking variables
    private var uploadedVideos: Int = 0
    
    func checkBadges() {
        uploadedVideos += 1
        checkFirstSteps()
        checkMilestone25()
        checkSecondIsBest()
        checkMilestone10()
        checkMilestone50()
        checkYourePoppin()
    }
    
    private func checkFirstSteps() {
        if !badges[0].isAchieved {
            badges[0].isAchieved = uploadedVideos > 0
        }
    }
    
    private func checkMilestone25() {
        if !badges[1].isAchieved {
            badges[1].isAchieved = uploadedVideos >= 25
        }
    }
    
    private func checkSecondIsBest() {
        if !badges[2].isAchieved {
            badges[2].isAchieved = uploadedVideos >= 2
        }
    }
    
    private func checkMilestone10() {
        if !badges[3].isAchieved {
            badges[3].isAchieved = uploadedVideos >= 10
        }
    }
    
    private func checkMilestone50() {
        if !badges[4].isAchieved {
            badges[4].isAchieved = uploadedVideos >= 50
        }
    }
    
    private func checkYourePoppin() {
        if !badges[5].isAchieved {
            badges[5].isAchieved = uploadedVideos >= 5
        }
    }
    
    // Retrieve badges based on visibility setting
    func getVisibleBadges(for currentUserID: String, friendIDs: Set<String>) -> [Badge] {
        switch visibility {
        case .justMe:
            return achievedBadges()
        case .friends:
            return friendIDs.contains(currentUserID) ? achievedBadges() : []
        case .everyone:
            return achievedBadges()
        }
    }
    
    func achievedBadges() -> [Badge] {
        return badges.filter { $0.isAchieved }
    }
    
    func unachievedBadges() -> [Badge] {
        return badges.filter { !$0.isAchieved }
    }
}
