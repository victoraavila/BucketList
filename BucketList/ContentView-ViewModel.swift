//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Víctor Ávila on 27/07/24.
//

import CoreLocation // So we have CLLocationCoordinate2D()
import Foundation
import LocalAuthentication
import MapKit

// This will handle our Map work by creating a new class that manages our data and manipulates it on behalf of ContentView
// (ContentView won't care how the underlying data system works)
// 1. A new @Observable class, so we can report back changes to any SwiftUI View watching it. We will place this class inside an extension on ContentView.
// 2.

extension ContentView { // Therefore, this is the ViewModel for ContentView.
    // Why to place our ViewModel inside a ContentView extension?
    // Think about how it would be to have 500 Views. If we want to call it inside ContentView, we would just call it as ViewModel (and it would be this ViewModel without clash).
    // Otherwise, we would have to name each one of the 500 ViewModels with an unique name.
    
    // Having all this functionality in a separate class makes it much easier to test your code
    @Observable
    class ViewModel {
        // Which pieces of state from ContentView should go into this ViewModel?
        // Some people say to move it all; some people say to be selective.
        // Remember to replace them back on ContentView with an instance of our ViewModel (for example, locations become viewModel.locations)
        
        // private(set) indicates that you can read these variables from outside, but cannot change.
        // We don't need to initialize locations here, since it will be initialized at the init()
        private(set) var locations: [Location] // Classes don't have @State and they're not private (so they can be read elsewhere)
        var selectedPlace: Location?
        
        // We're going to require users to authenticate using FaceID, TouchID or OpticID (Vision Pro) in order to see their saved locations, since this is private data.
        // 1. Add this variable to track whether the app is unlocked.
        // 2. Add the FaceID permission request to our Project Configuration options. (BucketList > BucketList (Targets) > Info Tab > Right click any and choose Add Row > Select Privacy - Face ID Usage Description > Insert "Please authenticate yourself to unlock places." in the corresponding value.
        // 3. Import LocalAuthentication.
        // 4. Since the code for biometric authentication is ObjectiveC, is good to write it far from SwiftUI. We will do that inside authenticate().
//        var isUnlocked = false
        var isUnlocked = true
        
        // Track failed attempts
        var failedAttempts = 0
        let maxFailedAttempts = 3
        var isBlocked = UserDefaults.standard.bool(forKey: "isBlocked")
        var authFailed = false
        var noBiometricsAvailable = false
        
        var mapMode = "Standard"
        
        // We will use this path when loading and saving the Codable object
        // We defined it as a constant so we don't need to change in both places when we need to change it
        let savePath = URL.documentsDirectory.appending(path: "SavedPlaces")
        
        // Loading and saving data by looking in the Documents/ for a particular file then use JSONDecoder() or JSONEncoder() to convert it ready to use
        // Loading, decoding and getting data ready to use will be made by a new initializer and saving will be made by a particular method
        init() {
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
        }
        
        // Making sure it is written with encryption and atomically.
        // By using .completeFileProtection, it will only be read when the user unlocks the device.
        // Using this approach, we can save any amount of data into any amount of files. It is much more flexible than UserDefaults, since it lets us load and save data when it is needed, and not only when the app is launched.
        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomic, .completeFileProtection]) // .atomic means that it will be written in a temporary file first
            } catch {
                print("Unable to save data.")
            }
        }
        
        func addLocation(at point: CLLocationCoordinate2D) {
            // The same code from ContentView
            let newLocation = Location(id: UUID(), name: "New location", description: "", latitude: point.latitude, longitude: point.longitude)
            locations.append(newLocation)
            save()
        }
        
        func update(location: Location) {
            // Making sure we actually have a place to modify in the first place
            guard let selectedPlace else { return }
            
            // The same code from ContentView
            if let index = locations.firstIndex(of: selectedPlace) {
                locations[index] = location
                save()
            }
        }
        
        // Creating a LAContext so we can check and perform biometric authentication
        // 1. Ask if our device is capable of doing authentication;
        // 2. If so, we'll start the request and provide a closure to run when it completes;
        // 3. When it finishes, if the result is successful, set isUnlocked to true.
        func authenticate() {
            let context = LAContext()
            var error: NSError? // Handle any errors that happpen (ObjectiveC stuff)
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authenticate yourself to unlock your places." // This string is for TouchId. The string put in Info.plist is for FaceID.
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authentaticationError in
                    if success {
                        self.isUnlocked = true
                        self.failedAttempts = 0
                    } else {
                        // error
                        self.authFailed = true
                        self.failedAttempts += 1
                        if self.failedAttempts >= self.maxFailedAttempts {
                            self.isBlocked = true
                            UserDefaults.standard.setValue(self.isBlocked, forKey: "isBlocked")
                        }
                    }
                }
            } else {
                // no biometrics (the user has an iPod Touch or haven't enabled biometrics, etc.)
                self.noBiometricsAvailable = true
            }
        }
    }
}
