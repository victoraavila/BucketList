//
//  Location.swift
//  BucketList
//
//  Created by Víctor Ávila on 23/07/24.
//

import Foundation

// Creating a type definition of the locations we want to store. This MUST conform to Identifiable (so we can create many location markers in our app), Codable (so we can load and save map data easily) and Equatable (so we can find one particular location in an Array of locations). The struct will have an identifier (so we can create it dynamically), a name, a description, a latitude and a longitude.
struct Location: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var description: String
    
    // We are not using CLLocationCoordinate2D() because it does not work with Codable for Apple reasons
    var latitude: Double
    var longitude: Double
}
