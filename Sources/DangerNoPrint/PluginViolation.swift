//
//  PluginViolation.swift
//  DangerNoPrint
//
//  Created by Darren Lai on 3/7/20.
//

import Danger
import Foundation

struct PluginViolation {
    let message: String
    let file: String
    let line: Int
    
    init(message: String, file: String, line: Int) {
        self.message = message
        self.file = file
        self.line = line
    }
    
    func toMarkdown() -> String {
        let formattedFile = file.split(separator: "/").last! + ":\(line)"
        return "| \(formattedFile) | \(message) |"
    }
}
