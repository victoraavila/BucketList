//
//  Location.swift
//  BucketList
//
//  Created by Víctor Ávila on 23/07/24.
//

import Foundation
import MapKit

// Creating a type definition of the locations we want to store. This MUST conform to Identifiable (so we can create many location markers in our app), Codable (so we can load and save map data easily) and Equatable (so we can find one particular location in an Array of locations). The struct will have an identifier (so we can create it dynamically), a name, a description, a latitude and a longitude.
struct Location: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var description: String
    
    // We are not using CLLocationCoordinate2D() because it does not work with Codable for Apple reasons
    var latitude: Double
    var longitude: Double
    
    // A few improvements were added to this struct to make it better:
    // 1. It's better to create the CLLocationCoordinate2D() here as a computer property than amongst UI code
    // 2. It's good to provide example data for previews when building custom data types, so we can see exactly how it will look like
    // 3. Add a custom == method to this struct (without it, Swift is synthesizing equality as a member-wise comparison since it is conforming to Equatable. This means that two instances are equal ONLY if all 5 properties are the same. Comparing id to id is useless, since it's guaranteed that they will be unique.). @twostraws considers it important that every struct conforms to Equatable.
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    #if DEBUG // So it won't be compiled into the release build (this is for Xcode testing purposes)
    static let example = Location(id: UUID(), name: "Buckingham Palace", description: "Lit by over 40,000 lightbulbs.", latitude: 51.501, longitude: -0.141)
    #endif
    
    static func == (lhs: Location, rhs: Location) -> Bool { // lhs is left-hand side and rhs is right-hand side
        // If you update a location's name or coordinates, it's still considered the same location.
        // Two locations with identical names and coordinates but different ids are considered different locations.
        lhs.id == rhs.id
    }
}
