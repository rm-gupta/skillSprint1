//
//  BadgeManager.swift
//  skillSprint
//
//  Created by Jeanie Ho on 11/04/24.
//

// Badge class
struct Badge {
    let name: String
    let description: String
    let iconName: String
    var isAchieved: Bool
}

class BadgeManager {
    static let shared = BadgeManager()
    
    var badges: [Badge] = [
        Badge(name: "First Steps", description: "Complete your first skill or upload your first video", iconName: "badge_1", isAchieved: false),
        Badge(name: "Explorer", description: "Try 5 different skills", iconName: "badge_2", isAchieved: false),
        Badge(name: "Jack of All Trades", description: "Try a skill in every difficulty", iconName: "badge_3", isAchieved: false),
        Badge(name: "Milestone Achiever", description: "Reach a milestone of completed skills", iconName: "badge_4", isAchieved: false),
        Badge(name: "Social Butterfly", description: "Engage with the community by liking or commenting on others’ videos", iconName: "badge_5", isAchieved: false),
        Badge(name: "Helpful Mentor", description: "Earn 5+ likes on your videos", iconName: "badge_6", isAchieved: false),
        Badge(name: "Supportive Buddy", description: "Add a friend on SkillSprint", iconName: "badge_1", isAchieved: false)
    ]
    
    // Badge progress tracking variables
    private var completedSkills: Int = 0
    private var differentSkillsTried: Set<String> = []
    private var difficultiesTried: Set<String> = []
    private var likesReceived: Int = 0
    private var friendsAdded: Int = 0
    private var communityInteractions: Int = 0
    
    // Function to add a test badge
    func addTestBadge() {
        let testBadge = Badge(name: "Test Badge", description: "This is a test badge", iconName: "badge_1", isAchieved: true)
        let testBadge2 = Badge(name: "Test 2", description: "This is a test badge", iconName: "badge_1", isAchieved: true)
        let testBadge3 = Badge(name: "Test 3", description: "This is a test badge", iconName: "badge_1", isAchieved: true)
        badges.append(testBadge)
        badges.append(testBadge2)
        badges.append(testBadge3)

    }
    
    // Badge check methods
    func completeSkill() {
        completedSkills += 1
        checkMilestoneAchiever()
        checkExplorer()
        checkJackOfAllTrades()
        checkFirstSteps()
    }
    
    func uploadVideo() {
        checkFirstSteps()
    }
    
    func interactWithCommunity() {
        communityInteractions += 1
        checkSocialButterfly()
    }
    
    func receiveLikeOnVideo() {
        likesReceived += 1
        checkHelpfulMentor()
    }
    
    func addFriend() {
        friendsAdded += 1
        checkSupportiveBuddy()
    }
    
    // Badge check implementations
    private func checkFirstSteps() {
        if !badges[0].isAchieved {
            badges[0].isAchieved = completedSkills > 0 || communityInteractions > 0
        }
    }
    
    private func checkExplorer() {
        if !badges[1].isAchieved {
            badges[1].isAchieved = differentSkillsTried.count >= 5
        }
    }
    
    private func checkJackOfAllTrades() {
        if !badges[2].isAchieved {
            badges[2].isAchieved = difficultiesTried.count >= 3
        }
    }
    
    private func checkMilestoneAchiever() {
        if !badges[3].isAchieved {
            badges[3].isAchieved = completedSkills >= 10
        }
    }
    
    private func checkSocialButterfly() {
        if !badges[4].isAchieved {
            badges[4].isAchieved = communityInteractions >= 1
        }
    }
    
    private func checkHelpfulMentor() {
        if !badges[5].isAchieved {
            badges[5].isAchieved = likesReceived >= 5
        }
    }
    
    private func checkSupportiveBuddy() {
        if !badges[6].isAchieved {
            badges[6].isAchieved = friendsAdded >= 1
        }
    }
    
    // Retrieve badges for display purposes
    func achievedBadges() -> [Badge] {
        return badges.filter { $0.isAchieved }
    }
    
    func unachievedBadges() -> [Badge] {
        return badges.filter { !$0.isAchieved }
    }
}
