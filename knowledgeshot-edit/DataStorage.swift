//
//  DataStorage.swift
//  Knowledgeshot Editor
//
//  Created by ptgms on 06.12.20.
//

import Foundation

class DataStorage {
    
    static let shared = DataStorage()
    
    var authorName: String?
    var authorURL: String?
    var authorImageURL: String?
    var pageTitle: String?
    var writtenOnDate: String?
    var imageURL: String?
    var sources: [String]?
    
}
