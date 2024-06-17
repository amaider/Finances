// 2024-04-24, Swift 5.0, macOS 14.4, Xcode 15.2
// Copyright © 2024 amaider. All rights reserved.

import Foundation
import CoreLocation
import MapKit

// Info.plist -> Privacy - Location When In Use Usage Descirption

class LocationService: NSObject {
    private let manager: CLLocationManager
    private var locationContinuation: CheckedContinuation<CLLocation?, Never>?
    
    // private let completer: MKLocalSearchCompleter
    // private var shopsContinuation: CheckedContinuation<[ShopEntity], Never>?
    
    override init() {
        self.manager = CLLocationManager()
        //        self.completer = MKLocalSearchCompleter()
        
        super.init()
        
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        if manager.authorizationStatus != .authorizedWhenInUse && manager.authorizationStatus != .authorizedAlways {
            manager.requestWhenInUseAuthorization()
        }
        
        // self.completer.delegate = self
        // self.completer.resultTypes = .pointOfInterest
    }
    
    deinit {
        print("LocationService: deinit")
    }
    
    public func requestLocation() async -> CLLocation? {
        return await withCheckedContinuation({ continuation in
            self.locationContinuation = continuation
            
            guard manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse else {
                continuation.resume(returning: nil)
                return
            }
            
            manager.requestLocation()
        })
    }
    
    static public func searchShopsNearby(at location: CLLocation, query: String) async throws -> [MKMapItem] {
        let mapKitRequest: MKLocalSearch.Request = MKLocalSearch.Request()
        mapKitRequest.resultTypes = .pointOfInterest
        mapKitRequest.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1, longitudinalMeters: 1)
        mapKitRequest.naturalLanguageQuery = query
        
        let response: MKLocalSearch.Response = try await MKLocalSearch(request: mapKitRequest).start()
        /// restrict placemarks to max 1000m radius
        return response.mapItems.filter({ location.distance(from: $0.placemark.location ?? .init()) < 1000 })
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("location: locationManagerDidChangeAuthorization:", manager.authorizationStatus.rawValue)
        /// notDetermined = 0, restricted = 1, denied = 2, authorizedAlways = 3,authorizedWhenInUse = 4
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationContinuation?.resume(returning: locations.first)
        self.locationContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("location: didFailWithError:", error)
        self.locationContinuation?.resume(returning: nil)
        self.locationContinuation = nil
    }
}

// extension LocationService: MKLocalSearchCompleterDelegate {
//     func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
//         let shops: [ShopEntity] = completer.results.compactMap({
//             ShopEntity(name: $0.title, address: $0.subtitle, longitude: 99, latitude: 99)
//         })
//         self.shopsContinuation?.resume(returning: shops)
//         self.shopsContinuation = nil
//     }
//
//    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
//        print("completer: didFailWithError:", error)
//        self.completer.cancel()
//        self.shopsContinuation?.resume(returning: [])
//        // self.shopsContinuation = nil
//    }
// }
