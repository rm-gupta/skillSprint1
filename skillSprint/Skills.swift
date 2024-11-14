//
//  Skills.swift
//  skillSprint
//
//  Created by Heyu Zhou on 11/11/24.
//

// Class that contains attributes for the skills database.
class Skills {
    var id: String
    var title: String
    var desc: String
    var instr: String
    var difficulty: String
    init(id: String, title: String, desc: String, instr: String, difficulty: String) {
        self.id = id
        self.title = title
        self.desc = desc
        self.instr = instr
        self.difficulty = difficulty
    }
}

