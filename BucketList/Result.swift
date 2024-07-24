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

struct Page: Codable {
    let pageid: Int
    let title: String
    let terms: [String: [String]]? // An Optional dictionary that maps Strings to Arrays of Strings
}
