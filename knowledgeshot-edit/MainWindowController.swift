//
//  MainWindowController.swift
//  knowledgeshot-edit
//
//  Created by ptgms on 05.12.20.
//

import Foundation
import Cocoa

class MainWindowController: NSWindowController {
    @IBAction func rendPress(_ sender: Any) {
        NotificationCenter.default.post(name: .renderPress, object: nil)
    }
}
