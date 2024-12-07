//
//  SkillLibraryViewController.swift
//  skillSprint
//
//  Created by Heyu Zhou on 11/11/24.
//

import UIKit
import FirebaseFirestore // imported to store data

class SkillLibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var skillsList = [Skills]()
    var filteredList = [Skills]()
    var searchedList = [Skills]()
    let db = Firestore.firestore()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterBttn: UIButton!
    @IBOutlet weak var sortBttn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var sortOption: String!
    var filterOption: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 128
        fetchSkills()
        prepareDropdown()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dissmissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
    
    @objc private func dissmissKeyboard() {
        view.endEditing(true)
    }
    
    // Re-apply theme every time the view appears
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            applyTheme()
        }
    
    // Creates the dropdown choices for filter and sort functions
    func prepareDropdown() {
        let filterOptions = [
            UIAction(title: "Easy") { _ in
                self.filterOption = "easy"
                self.filterBttn.setTitle("Easy", for: .normal)
                self.updateChoices()},
            UIAction(title: "Medium") { _ in
                self.filterOption = "med"
                self.filterBttn.setTitle("Medium", for: .normal)
                self.updateChoices()},
            UIAction(title: "Hard") { _ in
                self.filterBttn.setTitle("Hard", for: .normal)
                self.filterOption = "hard"
                self.updateChoices()},
            UIAction(title: "All") { _ in
                self.filterOption = nil
                self.filterBttn.setTitle("Filter", for: .normal)
                self.updateChoices()},
        ]
        
        let sortOptions = [
            UIAction(title: "Easy First") { _ in
                self.sortOption = "easy"
                self.updateChoices()},
            UIAction(title: "Medium First") { _ in
                self.sortOption = "med"
                self.updateChoices()},
            UIAction(title: "Hard First") { _ in
                self.sortOption = "hard"
                self.updateChoices()},
        ]
        
        let filter = UIMenu(title:"Difficulty", options: .displayInline, children: filterOptions)
        filterBttn.menu = filter
        filterBttn.showsMenuAsPrimaryAction = true
        
        let sort = UIMenu(title:"Difficulty", options: .displayInline, children: sortOptions)
        sortBttn.menu = sort
        sortBttn.showsMenuAsPrimaryAction = true
    }
    
    // Filters the search results based on user input in search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterOption = nil
        sortOption = nil
        filterBttn.setTitle("Filter", for: .normal)
        
        guard !searchText.isEmpty else {
            // If search text is empty, show all items
            searchedList.removeAll()
            filteredList = skillsList
            tableView.reloadData()
            return
        }
        
        searchedList = skillsList.filter { skill in
            let titleContains = skill.title.lowercased().contains(searchText.lowercased())
            let descContains = skill.desc.lowercased().contains(searchText.lowercased())
            let instrContains = skill.instr.lowercased().contains(searchText.lowercased())
            return titleContains || descContains || instrContains
        }
        
        if searchedList.isEmpty {
            filteredList = []
        } else {
            // Update filteredList with the search results, then apply filters and sort
            filteredList = searchedList
            updateChoices()
        }
        
        tableView.reloadData()
    }
    
    // Updated the results after filter and sort are applied
    func updateChoices() {
        // when there is still text in the search bar, search from the keyword list
        if !searchedList.isEmpty {
            filteredList = searchedList
        } else {
            filteredList = skillsList
        }
        
        if let filter = filterOption {
            filteredList = filteredList.filter({ $0.difficulty == filter })
        }
        
        if let sort = sortOption {
            let difficultyOrder: [String: Int]
                    
            switch sort {
            case "easy":
                difficultyOrder = ["easy": 0, "med": 1, "hard": 2]
            case "med":
                difficultyOrder = ["med": 0, "easy": 1, "hard": 2]
            case "hard":
                difficultyOrder = ["hard": 0, "med": 1, "easy": 2]
            default:
                difficultyOrder = ["easy": 0, "med": 1, "hard": 2]
            }
                    
            filteredList.sort {
                let order1 = difficultyOrder[$0.difficulty.lowercased()] ?? 3
                let order2 = difficultyOrder[$1.difficulty.lowercased()] ?? 3
                return order1 < order2
            }
        }
                
        tableView.reloadData()
    }
    
    // Load the all the skills to skillsList from Firestore
    func fetchSkills() {
        db.collection("skills").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching skills: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("No documents in snapshot")
                return
            }
                        
            self.skillsList = documents.compactMap { document in
                let data = document.data()
                return Skills(
                    id: document.documentID,
                    title: data["title"] as? String ?? "",
                    desc: data["description"] as? String ?? "",
                    instr: data["instruction"] as? String ?? "",
                    difficulty: data["difficulty"] as? String ?? ""
                    )
                }
            self.filteredList = self.skillsList
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    // Returns the number of items to display in the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredList.count
    }
    
    // Sets the text in each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "individualSkill", for: indexPath) as! LibraryTableViewCell
        let row = indexPath.row // index of row number
        cell.titleLabel.text = filteredList[row].title

        let formattedInstructions = filteredList[row].desc.replacingOccurrences(of: "(\\d+\\.)", with: "\n$1", options: .regularExpression)
        cell.descLabel.text = formattedInstructions // sets text string label
        cell.difficultyLabel.text = "Difficulty: " + filteredList[row].difficulty
        return cell
    }
    
    // Make the cell gray only when tapping on it
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // When cell is pressed, leads user to the skill details screen, and
    // pass relevent information to the details screen
    override func prepare(for segue: UIStoryboardSegue, sender:Any?) {
        if segue.identifier == "libToDetail",
           let detailVC = segue.destination as? SkillDetailViewController,
           let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell)  {
            detailVC.delegate = self
            let curSkill = filteredList[indexPath.row]
            detailVC.skillTitle = curSkill.title
            detailVC.skillDesc = curSkill.desc
            detailVC.skillInstr = curSkill.instr
            detailVC.skillDiff = curSkill.difficulty
        }
    }
    
    private func applyTheme() {
        view.backgroundColor = ColorThemeManager.shared.backgroundColor
        tableView.backgroundColor = ColorThemeManager.shared.backgroundColor

    }
    

}

