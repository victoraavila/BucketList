//
//  Result.swift
//  BucketList
//
//  Created by Víctor Ávila on 24/07/24.
//

import Foundation

struct Result: Codable {
    let query: Query
}

struct Query: Codable {
    let pages: [Int: Page]
}

struct Page: Codable, Comparable {
    let pageid: Int
    let title: String
    let terms: [String: [String]]? // An Optional dictionary that maps Strings to Arrays of Strings
    
    // Page Results do have a description inside the terms dictionary, which is Optional
    // If it does exist, it might or might not have a description key
    // If it has a description key, it might be an empty Array rather than an Array with content
    // Therefore, we have to write a custom computed property to handle it
    var description: String {
        terms?["description"]?.first ?? "No further information"
    }
    
    // Perhaps you should sort your values in a custom order: news stories sorted newest to oldest, contacts sorted last name then first name. For this reason, we will make our Page struct conform to Comparable (we MUST implement a < function with two parameters of the same Page struct and returning true if the first one comes before the second one).
    static func < (lhs: Page, rhs: Page) -> Bool {
        lhs.title < rhs.title
    }
    // Now, Swift understands how to sort Pages
    
}
