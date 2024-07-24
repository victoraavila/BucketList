//
//  EditView.swift
//  BucketList
//
//  Created by Víctor Ávila on 23/07/24.
//

import SwiftUI

// This View has to be given a Location to edit and allow the user to adjust name and description for that Location, sending back a new Location with the tweaked data.

struct EditView: View {
    @Environment(\.dismiss) var dismiss
    var location: Location
    
    @State private var name: String
    @State private var description: String
    
    // You MUST pass in a saving function to this View. This function accepts a single Location to edit and returns nothing.
    var onSave: (Location) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Place name", text: $name)
                    TextField("Description", text: $description)
                }
            }
            .navigationTitle("Place details")
            .toolbar {
                Button("Save") {
                    // How can we actually pass back the new location's data?
                    // We could use something like @Binding to pass in a value from elsewhere, but we want EditView to work with a real Location, not a Location? from ContentView.
                    // Instead, we will require a function to call where we can pass back whatever new location we want. (Any other SwiftUI View can send us some data to work with and get back some new data).
                    var newLocation = location // Since this is a copy, we get access to location's identifier, latitude and longitude.
                    // Setting a new UUID, so the new (same) location will be different than the old (same) location and it will save the changes:
                    newLocation.id = UUID()
                    newLocation.name = name
                    newLocation.description = description
                    
                    onSave(newLocation)
                    dismiss()
                }
            }
        }
    }
    
    // What initial values should be used for name and description? They should come from location being passed in.
    // The solution is to create a new initializer that accepts location and uses that to create name and description with the current values of the location. Inside, we will create an instance of the property wrapper directly.
    init(location: Location, onSave: @escaping (Location) -> Void) {
        self.location = location
        
        // Swift wants to know if this function will be used straight away or not (the default is straight away, which means the function will run along the initializer). When we add @escaping to the parameters we tell Swift we will not use the function during initialization (this takes a little time, but it is important).
        self.onSave = onSave
        
        // Let's make the properties name and description to be a new piece of State
        _name = State(initialValue: location.name)
        _description = State(initialValue: location.description)
    }
}

#Preview {
    EditView(location: .example) { _ in } // Using a placeholder for the function
}
