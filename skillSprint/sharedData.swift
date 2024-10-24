//
//  sharedData.swift
//  skillSprint
//
//  Created by Ritu Gupta on 10/23/24.
//

class SharedData {
    static let shared = SharedData()
    // Remove the email suffix 
    var username: String? {
        didSet {
            // Automatically update username to exclude everything after '@'
            if let currentUsername = username {
                username = currentUsername.components(separatedBy: "@").first
            }
        }
    }
    
    // Set the '@' prefix
    var usernameWithAtSymbol: String? {
        if let user = username {
            return "@" + user
        }
        return nil
    }
}
