//
//  ContentView.swift
//  BucketList
//
//  Created by Víctor Ávila on 23/07/24.
//

// This project consists in a Map View asking users to add places to the map that they want to visit
// 1. We have to place a map that takes up the whole screen;
// 2. Track its annotations;
// 3. Make sure we store whether the user is viewing one particular place details or not.
import MapKit
import SwiftUI

struct ContentView: View {
    // The start position of the map
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 56, longitude: -3),
                           span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    )
    
    // We have to pass in to the Map an Array of locations the user wants to visit
    @State private var locations = [Location]()
    
    var body: some View {
        MapReader { proxy in
            // A Map View with an initial position that shows the whole of UK
            Map(initialPosition: startPosition) {
                // Updating the map by creating markers for each one of the locations in our Array
                ForEach(locations) { location in
                    Marker(location.name,
                           coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                }
            }
                .mapStyle(.hybrid) // Satellite pictures + place and road names
            
            // Letting the users tap around the map to add place marks
            // We will use a .tapGesture instead of a Button, because it is a modifier that triggers code when it's tapped and can be attached to any SwiftUI View.
            // DO NOT overuse .tapGesture: it can cause problems for users who rely on screen readers. It is almost always a better idea to use a Button or other control View. In this case we have no choice: a Button can't tell us where in the Map the user tapped.
            // Tap gestures won't interfere with regular gestures like zoom in, drag, etc.
            .onTapGesture { position in // position is given in screen coordinates, which aren't ideal
                if let coordinate = proxy.convert(position, from: .local) { // coordinate is given in GPS coordinates
                    let newLocation = Location(id: UUID(), name: "New location", description: "", latitude: coordinate.latitude, longitude: coordinate.longitude)
                    locations.append(newLocation)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
