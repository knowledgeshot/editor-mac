//
//  AppDelegate.swift
//  knowledgeshot-edit
//
//  Created by ptgms on 05.12.20.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    @IBAction func savePressed(_ sender: Any) {
        NotificationCenter.default.post(name: .savePress, object: nil)
    }
    
    @IBAction func openPressed(_ sender: Any) {
        NotificationCenter.default.post(name: .openPress, object: nil)
    }
    
    @IBAction func newPressed(_ sender: Any) {
        NotificationCenter.default.post(name: .newPress, object: nil)
    }
    
    @IBAction func closePressed(_ sender: Any) {
        NotificationCenter.default.post(name: .closePress, object: nil)
    }
}

extension Notification.Name {
    static let savePress = Notification.Name("savePress")
    static let openPress = Notification.Name("openPress")
    static let newPress = Notification.Name("newPress")
    static let closePress = Notification.Name("closePress")
    
    static let renderPress = Notification.Name("renderPress")
    
    static let newConfirmed = Notification.Name("newConfirm")
    static let initial = Notification.Name("initial")
    static let opened = Notification.Name("opened")
}
