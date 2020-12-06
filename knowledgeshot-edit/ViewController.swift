//
//  ViewController.swift
//  knowledgeshot-edit
//
//  Created by ptgms on 05.12.20.
//

import Cocoa
import Foundation
import SwiftyMarkdown

struct FileOpen: Codable {
    let author, links: [String]
    let title: String
    let image: [String]
    let text: String

    enum CodingKeys: String, CodingKey {
        case author, links
        case title = "Title"
        case image, text
    }
}


class ViewController: NSViewController {
    
    @IBOutlet var articleTextField: NSTextView!
    
    
    @IBOutlet var previewField: NSTextView!
    
    
    var unsavedWork = true
    
    static let shareInstance = DataStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let font = NSFont(name: "Arial", size: 15)
        let attributes = NSDictionary(object: font!, forKey: NSAttributedString.Key.font as NSCopying)
                
        articleTextField.typingAttributes = attributes as! [NSAttributedString.Key : Any]
        articleTextField.textColor = NSColor.textColor
        articleTextField.string = "# Markdown Compatible text goes here"
        
        NotificationCenter.default.addObserver(self, selector: #selector(newPressed), name: .newPress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openPressed), name: .openPress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(savePressed), name: .savePress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closePressed), name: .closePress, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(renderPreview), name: .renderPress, object: nil)
        
        articleTextField.becomeFirstResponder()
        
        NotificationCenter.default.post(name: .initial, object: nil)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @objc func renderPreview() {
        let md = SwiftyMarkdown(string: articleTextField.string)
        md.h1.fontSize = 30
        md.h2.fontSize = 25
        md.h3.fontSize = 20
        md.h4.fontSize = 15
        md.h5.fontSize = 13
        md.h6.fontSize = 10
        md.body.fontSize = 15
        md.code.fontName = "CourierNewPSMT"
        previewField.textStorage?.setAttributedString(md.attributedString())
    }
    
    @objc func newPressed() {
        if unsavedWork {
            let alert = NSAlert()
            alert.messageText = "Unsaved work"
            alert.informativeText = "You have unsaved work. Do you want to save it?"
            alert.addButton(withTitle: "Save")
            alert.addButton(withTitle: "Continue")
            alert.addButton(withTitle: "Cancel")
            
            let result = alert.runModal()
            switch (result) {
            case .alertFirstButtonReturn:
                if (savePressed()) {
                    break
                } else {
                    WarningBox(title: "Saving failed!", text: "The saving process failed. Check if you didn't enter any illegal characters.")
                    return
                }
            case .alertSecondButtonReturn:
                break
            case .alertThirdButtonReturn:
                return
            default:
                break
            }
            
            articleTextField.string = "# Markdown Compatible text goes here"
            unsavedWork = true
        }
    }

    @objc func openPressed() {
        let dialog = NSOpenPanel()
        
        dialog.title = "Select the Article JSON to open"
        dialog.allowedFileTypes = ["json"]
        dialog.showsResizeIndicator = true
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url

            if (result != nil) {
                let path: String = result!.path
                print(path)
                do {
                    let json = try String(contentsOf: result!.absoluteURL, encoding: .utf8)
                    let fileOpen = try FileOpen(json)
                    
                    var image = ""
                    
                    if (fileOpen.image.count != 0) {
                        image = fileOpen.image[0]
                    }
                    
                    articleTextField.string = fileOpen.text
                    
                    ViewController.shareInstance.pageTitle = fileOpen.title
                    ViewController.shareInstance.authorImageURL = fileOpen.author[1]
                    ViewController.shareInstance.authorURL = fileOpen.author[3]
                    ViewController.shareInstance.authorName = fileOpen.author[0]
                    ViewController.shareInstance.sources = fileOpen.links
                    ViewController.shareInstance.imageURL = image
                    
                    NotificationCenter.default.post(name: .opened, object: nil)
                    
                    unsavedWork = true
                    
                } catch {
                    print(error)
                    
                }
            }
            
        }
    }
    
    @objc func savePressed() -> Bool {
        var authorImageURL = ViewController.shareInstance.authorImageURL
        var authorURL = ViewController.shareInstance.authorURL
        if (ViewController.shareInstance.authorName == "") {
            WarningBox(title: "Missing information", text: "Enter an Author Name")
            return false
        }
        
        if (ViewController.shareInstance.pageTitle == "") {
            WarningBox(title: "Missing information", text: "Enter an Page Title")
            return false
        }
        
        if (articleTextField.string == "") {
            WarningBox(title: "Missing information", text: "Enter Article Text")
            return false
        }
        
        if (authorImageURL == "") {
            authorImageURL = "nil"
        }
        if (authorURL == "") {
            authorURL = "nil"
        }
        
        let author = [ViewController.shareInstance.authorName, authorImageURL, ViewController.shareInstance.writtenOnDate, authorURL]
        let mainObject: NSMutableDictionary = NSMutableDictionary()
        
        mainObject.setValue(ViewController.shareInstance.pageTitle, forKey: "Title")
        mainObject.setValue(articleTextField.string.replacingOccurrences(of: "\n", with: "\n"), forKey: "text")
        mainObject.setValue([ViewController.shareInstance.imageURL], forKey: "image")
        mainObject.setValue(author, forKey: "author")
        mainObject.setValue(ViewController.shareInstance.sources, forKey: "links")
        
        let jsonData: NSData
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: mainObject, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
            print("json string = \(jsonString)")
            
            return saveFileExp(stringDat: jsonString, fileName: ViewController.shareInstance.pageTitle!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)

        } catch _ {
            print ("JSON Failure")
            return false
        }
    }
    
    @objc func closePressed() {
        if (savePressed()) {
            newPressed()
        } else {
            WarningBox(title: "Saving failed!", text: "The saving process failed. Check if you didn't enter any illegal characters.")
        }
        
    }
    
    func saveFileExp(stringDat: String, fileName: String) -> Bool {
        let dialog = NSSavePanel()
        
        dialog.title = "Where should the article be saved?"
        dialog.allowedFileTypes = ["json"]
        dialog.showsResizeIndicator = true
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url

            if (result != nil) {
                let path: String = result!.path
                print(path)
                do {
                    try stringDat.write(to: result!.absoluteURL, atomically: true, encoding: String.Encoding.utf8)
                    unsavedWork = false
                    return true
                } catch {
                    print(error)
                    return false
                }
            }
            
        } else {
            return false
        }

        return false
    }
        
    func WarningBox(title: String, text: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.addButton(withTitle: "OK")
        
        alert.runModal()
    }
    
}

extension FileOpen {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FileOpen.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        author: [String]? = nil,
        links: [String]? = nil,
        title: String? = nil,
        image: [String]? = nil,
        text: String? = nil
    ) -> FileOpen {
        return FileOpen(
            author: author ?? self.author,
            links: links ?? self.links,
            title: title ?? self.title,
            image: image ?? self.image,
            text: text ?? self.text
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}


func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}
