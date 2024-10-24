//
//  PersonalProfileViewController.swift
//  skillSprint
//
//  Created by Ritu Gupta on 10/22/24.
//

import UIKit

protocol TextChanger {
    func changeName(newName: String)
    func changeTagline(newTagline: String)
}

protocol ProfileImageUpdater {
    func updateProfileImage(newImage: UIImage)
}

class PersonalProfileViewController: UIViewController, TextChanger, ProfileImageUpdater {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var profImgView: UIImageView!
    @IBOutlet weak var editProfButton: UIButton!
    
    var currentName: String?
    var currentTagline: String?
    

    
    let greenColor = UIColor(red: 125/255.0, green: 207/255.0, blue: 150/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the username label from SharedData
        usernameLabel.text = SharedData.shared.usernameWithAtSymbol
        
        editProfButton.backgroundColor = greenColor
        
        // Retrieve saved name and tagline from UserDefaults
        if let savedName = UserDefaults.standard.string(forKey: "savedName") {
            nameLabel.text = savedName
        }
        
        if let savedTagline = UserDefaults.standard.string(forKey: "savedTagline") {
            taglineLabel.text = savedTagline
        }
        
        //add gear icon button
        let settingsButton = UIButton(type: .system)
        
        // Set the custom image from your assets
        let gearImage = UIImage(named: "gearIcon")
        settingsButton.setImage(gearImage, for: .normal)
        settingsButton.tintColor = .black
        
        // Set button frame or constraints
        settingsButton.frame = CGRect(x: 35, y: 100, width: 30, height: 30)
        
        // Add button to the view
        view.addSubview(settingsButton)
        
        // Add camera shutter icon
        let shutterButton = UIButton(type: .system)
        
        // Set the custom image from your assets
        let shutterImage = UIImage(named: "camShutterIcon")
        shutterButton.setImage(shutterImage, for: .normal)
        shutterButton.tintColor = .black
        
        // Set button frame or constraints
        shutterButton.frame = CGRect(x: 340, y: 100, width: 30, height: 30)
        // Add button to the view
        view.addSubview(shutterButton)
        
        // Retrieve the stored URL
        if let imageUrlString = UserDefaults.standard.string(forKey: "profileImageURL"),
            let imageUrl = URL(string: imageUrlString) {
                downloadImage(from: imageUrl)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update the currentName and currentTagline with existing values
        currentName = nameLabel.text
        currentTagline = taglineLabel.text
        
        // Retrieve the stored URL
        if let imageUrlString = UserDefaults.standard.string(forKey: "profileImageURL"),
           let imageUrl = URL(string: imageUrlString) {
            downloadImage(from: imageUrl)
        }
        
    }
    
    func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    self.profImgView.image = image // Update the ImageView
                    print("Image updated successfully.")
                } else {
                    print("Failed to create image from data.")
                }
            }
        }.resume()
    }
    
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditProfileSegue",
           let nextVC = segue.destination as? EditProfileViewController {
                nextVC.delegateText = self
                // Pass the current name and tagline to the edit profile view controller
                nextVC.currentName = nameLabel.text
                nextVC.currentTagline = taglineLabel.text
        }
    }

    // If the name field is changed
    func changeName(newName: String) {
        nameLabel.text = newName
        // Save the name in UserDefaults
        UserDefaults.standard.set(newName, forKey: "savedName")
    }
    
    // If the tagline field is changed
    func changeTagline(newTagline: String) {
        taglineLabel.text = newTagline
        // Save the tagline in UserDefaults
        UserDefaults.standard.set(newTagline, forKey: "savedTagline")
    }
    
    func updateProfileImage(newImage: UIImage) {
        profImgView.image = newImage
    }
    
    

}
