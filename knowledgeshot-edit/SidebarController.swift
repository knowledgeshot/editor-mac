//
//  SidebarController.swift
//  Knowledgeshot Editor
//
//  Created by ptgms on 06.12.20.
//

import Foundation
import Cocoa

class SidebarController: NSViewController {
    
    @IBOutlet weak var PageTitleTextField: NSTextField!
    @IBOutlet weak var AuthorImageURLTextField: NSTextField!
    @IBOutlet weak var AuthorNameTextField: NSTextField!
    @IBOutlet weak var WrittenOnField: NSTextField!
    @IBOutlet weak var AuthorURLField: NSTextField!
    @IBOutlet weak var imageURLField: NSTextField!
    @IBOutlet weak var sourcesField: NSTextField!
    @IBOutlet weak var AuthorImagePreview: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(newConfirmed), name: .newConfirmed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(initialised), name: .initial, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(opened), name: .opened, object: nil)
    }
    
    @objc func initialised() {
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: "en_US")
        formatter.setLocalizedDateFormatFromTemplate("d. MMMM YYYY")
        
        ViewController.shareInstance.writtenOnDate = formatter.string(from: date)
        WrittenOnField.stringValue = ViewController.shareInstance.writtenOnDate!
    }
    
    @objc func newConfirmed() {
        PageTitleTextField.stringValue = ""
        AuthorImageURLTextField.stringValue = ""
        AuthorURLField.stringValue = ""
        AuthorNameTextField.stringValue = ""
        sourcesField.stringValue = ""
        imageURLField.stringValue = ""
    }
    
    @objc func opened() {
        PageTitleTextField.stringValue = ViewController.shareInstance.pageTitle!
        AuthorImageURLTextField.stringValue = ViewController.shareInstance.authorImageURL!
        AuthorURLField.stringValue = ViewController.shareInstance.authorURL!
        AuthorNameTextField.stringValue = ViewController.shareInstance.authorName!
        sourcesField.stringValue = ViewController.shareInstance.sources!.joined(separator: ",")
        imageURLField.stringValue = ViewController.shareInstance.imageURL!
        
        downloadImage(from: URL(string: AuthorImageURLTextField.stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!, imageView: AuthorImagePreview)
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func done() {
        
    }
    
    func downloadImage(from url: URL, imageView: NSImageView) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { [weak self] in
                imageView.image = NSImage(data: data)
                self?.done()
            }
        }
    }
    
    @IBAction func authorImageSet(_ sender: Any) {
        if (AuthorImageURLTextField.stringValue == "") {
            if #available(OSX 11.0, *) {
                AuthorImagePreview.image = NSImage(systemSymbolName: "person.crop.circle.fill.badge.questionmark", accessibilityDescription: nil)
            } else {
                AuthorImagePreview.image = NSImage(named: "person.crop.circle.fill.badge.xmark")
            }
        } else {
            if (!AuthorImageURLTextField.stringValue.starts(with: "https://")) {
                WarningBox(title: "The image URL provided must be HTTPS!", text: "This is to assure security and make all calls to external sources as secure as possible.")
                AuthorImageURLTextField.stringValue = ""
                return
            } else {
                print(AuthorImageURLTextField.stringValue)
                ViewController.shareInstance.authorImageURL = AuthorImageURLTextField.stringValue
                downloadImage(from: URL(string: AuthorImageURLTextField.stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!, imageView: AuthorImagePreview)
            }
        }
    }
    
    @IBAction func pageTitleConfirm(_ sender: Any) {
        ViewController.shareInstance.pageTitle = PageTitleTextField.stringValue
    }
    
    @IBAction func imageURLConfirm(_ sender: Any) {
        ViewController.shareInstance.imageURL = imageURLField.stringValue
    }
    
    @IBAction func sourcesConfirm(_ sender: Any) {
        if sourcesField.stringValue == "" {
            ViewController.shareInstance.sources = []
        } else {
            ViewController.shareInstance.sources = sourcesField.stringValue.components(separatedBy: ",")
        }
    }
    
    @IBAction func authorConfirm(_ sender: Any) {
        ViewController.shareInstance.authorURL = AuthorURLField.stringValue
    }
    
    @IBAction func authorNameConfirm(_ sender: Any) {
        ViewController.shareInstance.authorName = AuthorNameTextField.stringValue
    }
    
    func WarningBox(title: String, text: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.addButton(withTitle: "OK")
        
        alert.runModal()
    }
    
}
