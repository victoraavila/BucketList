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
    }
}
