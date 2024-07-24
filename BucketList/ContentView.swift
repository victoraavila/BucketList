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

// For now, users cannot add name, neither description, neither anything to the annotations
// Fixing this requires a few steps:
// 1. Show a sheet when the user selects a map annotation that will allow them to edit details or go ahead and view. Instead of using a Bool and passing in the Location, this time only one property will be used for the sheet to appear and edit data.

struct ContentView: View {
    // The start position of the map
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 56, longitude: -3),
                           span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    )
    
    // We have to pass in to the Map an Array of locations the user wants to visit
    @State private var locations = [Location]()
    
    // For now, users cannot add name, neither description, neither anything to the annotations
    // Fixing this requires a few steps:
    // 1. Show a sheet when the user selects a map annotation that will allow them to edit details or go ahead and view. Instead of using a Bool and passing in the Location, this time only one property will be used for the sheet to appear and edit data.
    @State private var selectedPlace: Location? // We might have a selected Location or we might not
    
    var body: some View {
        MapReader { proxy in
            // A Map View with an initial position that shows the whole of UK
            Map(initialPosition: startPosition) {
                // Updating the map by creating markers for each one of the locations in our Array
                ForEach(locations) { location in
                    // We will place a custom SwiftUI View instead of a regular Marker balloon by using Annotation
                    Annotation(location.name,
                               coordinate: location.coordinate) {
                        Image(systemName: "star.circle")
                            .resizable()
                            .foregroundStyle(.red)
                            .frame(width: 44, height: 44)
                            .background(.white)
                            .clipShape(.circle)
                        
                            // Setting selectedPlace to a value. Although in theory adding another .onTapGesture ought to work well, in practive the Map View frequently gets confused between selecting existing annotations and adding new ones. So, we will use .onLongPressGesture instead, which triggers some code when the user presses and holds on a View.
                            .onLongPressGesture {
                                selectedPlace = location
                            }
                    }
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
            
            // As soon as we place a value inside the Location?, we are telling SwiftUI to show the sheet. The value will be set back to nil automatically when the sheet is dismissed. SwiftUI unwraps the Location?, so when we create the contents we can always be sure there is a real value inside there.
            // This Optional Binding approach isn't always available, but it helps a lot when it is
            .sheet(item: $selectedPlace) { place in // selectedPlace might be a place or nothing at all, but place is always a Location
                // Presenting the EditView and sending the location that was selected by defining the onSave() method
                EditView(location: place) { newLocation in
                    // Finding the index position of the previous place
                    if let index = locations.firstIndex(of: place) {
                        // If we can find the index, overwrite the previous location
                        locations[index] = newLocation
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
