//
//  EditView-ViewModel.swift
//  BucketList
//
//  Created by Víctor Ávila on 29/07/24.
//

import Foundation

enum LoadingState {
    case loading, loaded, failed
}

extension EditView {
    @Observable
    class ViewModel {
        var name: String
        var description: String
        
        var location: Location
        var loadingState = LoadingState.loading
        var pages = [Page]()
        
        init(location: Location) {
            self.location = location
            self.name = location.name
            self.description = location.description
        }
        
        func updateLocation() -> Location {
            var newLocation = self.location
            newLocation.id = UUID()
            newLocation.name = self.name
            newLocation.description = self.description
            
            return newLocation
        }
        
        func fetchNearbyPlaces() async {
            let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(self.location.latitude)%7C\(self.location.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
            
            guard let url = URL(string: urlString) else {
                print("Bad URL: \(urlString)")
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let items = try JSONDecoder().decode(Result.self, from: data)
                
                self.pages = items.query.pages.values.sorted()
                self.loadingState = .loaded
            } catch {
                self.loadingState = .failed
            }
        }
    }
}
