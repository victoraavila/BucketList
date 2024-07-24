//
//  EditView.swift
//  BucketList
//
//  Created by Víctor Ávila on 23/07/24.
//

import SwiftUI

// We'll edit EditView so it shows nearby locations as suggestions
// This can be done by querying Wikipedia using GPS coordinates, which will return a list of places
// Wikipedia's API sends back a JSON:
// 1. The main result contains the result of our query in a key called "query";
// 2. Inside query there is a "pages" dictionary, with page IDs as the keys and Wikipedia pages as values.
// 3. Each page has a lot of information, including coordinates, terms, etc.
// We will use 3 linked structs to store this.

struct EditView: View {
    // Showing something while the fetching is being done, which means conditionally showing different UIs, i.e., using an enum that stores a load State
    enum LoadingState {
        case loading, loaded, failed // All possible states to represent the network request
    }
    
    @Environment(\.dismiss) var dismiss
    var location: Location
    
    @State private var name: String
    @State private var description: String
    
    // One property for the loading state and another to store an Array of Wikipedia pages once the fetch has completed
    @State private var loadingState = LoadingState.loading
    @State private var pages = [Page]()
    
    var onSave: (Location) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Place name", text: $name)
                    TextField("Description", text: $description)
                }
                
                // Our Wikipedia pages, if they've loaded (could be if/else if conditions as well)
                Section("Nearby...") {
                    switch loadingState {
                    case .loading:
                        Text("Loading...")
                    case .loaded:
                        ForEach(pages, id: \.pageid) { page in
                            Text(page.title)
                                .font(.headline)
                            
                            + Text(": ") + // The + operators make this one big Text View with different styling inside.
                            
                            Text("Page description here")
                                .italic()
                        }
                    case .failed:
                        Text("Please try again later.")
                    }
                }
            }
            .navigationTitle("Place details")
            .toolbar {
                Button("Save") {
                    var newLocation = location
                    newLocation.id = UUID()
                    newLocation.name = name
                    newLocation.description = description
                    
                    onSave(newLocation)
                    dismiss()
                }
            }
            .task {
                // This should be ran as soon as the view first gets shown on the screen
                await fetchNearbyPlaces()
            }
        }
    }
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        self.location = location
        
        self.onSave = onSave
        
        _name = State(initialValue: location.name)
        _description = State(initialValue: location.description)
    }
    
    // Fetching some data from Wikipedia, decoding that into a Result object, assigning its pages to our @State pages and setting our loadingState to be loaded
    func fetchNearbyPlaces() async {
        let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.latitude)%7C\(location.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
        
        // Transforming it into an actual URL
        guard let url = URL(string: urlString) else {
            print("Bad URL: \(urlString)") // There is String Interpolation in the URL, which might go wrong even it being typed out
            return
        }
        
        // The URL was created successfully
        do {
            let (data, _) = try await URLSession.shared.data(from: url) // Fetching
            let items = try JSONDecoder().decode(Result.self, from: data) // Decoding
            
            // We've got actual pages to work with
            pages = items.query.pages.values.sorted { $0.title < $1.title }
            loadingState = .loaded
        } catch { // If Fetching or Decoding fails
            loadingState = .failed
        }
    }
}

#Preview {
    EditView(location: .example) { _ in }
}
