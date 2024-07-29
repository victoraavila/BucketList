//
//  ContentView.swift
//  BucketList
//
//  Created by Víctor Ávila on 23/07/24.
//

import MapKit
import SwiftUI

// MVVM is an architectural design pattern: Model, View, ViewModel
// The name is counterintuituve: we will use it as a way of getting our program state and logic out of our view structs.

// It's a good idea to look at this View and analyse in which places data manipulation is being done, so we can move it elsewhere. For example, saving a new location and updating a location. Specially, it is simpler to move snippets where the variables are already in the ViewModel.
// Reading data from a ViewModel is fine, but writing to a ViewModel isn't. Why? Because the exercise is to separate logic from our layout.

// This approach is also better to write tests in the future.

// Why didn't we use MVVM earlier in the course?
// 1. It works really badly with SwiftData, at least by now.
// 2. There are lots of ways of structuring projects, so experiment different approaches to see which fits you.
struct ContentView: View {
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 56, longitude: -3),
                           span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    )
    
    // ContentView has no idea that viewModel is saving and loading data, for example
    @State private var viewModel = ViewModel() // Since we used extensions, we get specifically the ViewModel related to ContentView
    
    var body: some View {
        if viewModel.isUnlocked {
            ZStack(alignment: .bottomTrailing) {
                MapReader { proxy in
                    Map(initialPosition: startPosition) {
                        ForEach(viewModel.locations) { location in
                            Annotation(location.name,
                                       coordinate: location.coordinate) {
                                Image(systemName: "star.circle")
                                    .resizable()
                                    .foregroundStyle(.red)
                                    .frame(width: 44, height: 44)
                                    .background(.white)
                                    .clipShape(.circle)
                                    .onLongPressGesture {
                                        viewModel.selectedPlace = location
                                    }
                            }
                        }
                    }
                    .mapStyle(viewModel.mapMode == "Standard" ? .standard : .hybrid)
                    
                    .onTapGesture { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            viewModel.addLocation(at: coordinate)
                        }
                    }
                    
                    .sheet(item: $viewModel.selectedPlace) { place in
                        EditView(location: place) {
                            viewModel.update(location: $0)
                        }
                    }
                }
                
                HStack {
                    Button("Standard") {
                        viewModel.mapMode = "Standard"
                    }
                    .foregroundStyle(.black)
                    
                    Divider()
                        .background(.black)
                        .frame(width: 1, height: 20)
                    
                    Button("Hybrid") {
                        viewModel.mapMode = "Hybrid"
                    }
                    .foregroundStyle(.black)
                }
                .padding()
                .frame(maxHeight: 40)
                .background(
                    Color(UIColor.lightGray)
                        .opacity(0.6)
                )
                .clipShape(.capsule)
                .padding(.trailing, 10)
                
            }
        } else { // If we aren't unlocked
            // Button here to trigger authentication
            // To test, go to Features > Face ID > Enrolled
            Button("Unlock Places", action: viewModel.authenticate)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(.capsule)
        }
    }
}

// Command + . exits the app in the Simulator

#Preview {
    ContentView()
}
