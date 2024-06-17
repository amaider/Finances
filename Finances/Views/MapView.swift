// 2024-06-16, Swift 5.0, macOS 14.4, Xcode 15.2
// Copyright © 2024 amaider. All rights reserved.

import SwiftUI
import SwiftData
import MapKit

struct MapView: View {
    @Query var shops: [Shop]
    
    let isPreview: Bool
    @Binding var selectedShop: Shop?
    
    init(isPreview: Bool, searchTerm: String?, selectedShop: Binding<Shop?>) {
        self.isPreview = isPreview
        self._selectedShop = selectedShop
        
        // _shops = Query(filter: #Predicate { _ in
        //     if searchTerm?.isEmpty ?? false {
        //         return true
        //     } else {
        //         return true
        //     }
        // })
    }
    
    var body: some View {
        if isPreview {
            Map(interactionModes: .pan ,content: {
                if let selectedShop {
                    Marker(selectedShop.name, coordinate: selectedShop.mapItem.placemark.coordinate)
                        .tint(selectedShop.color)
                }
            })
        } else {
            Map(content: {
                if let selectedShop {
                    Marker(selectedShop.name, coordinate: selectedShop.mapItem.placemark.coordinate)
                        .tint(selectedShop.color)
                }
                
                ForEach(shops, content: { shop in
                    Marker(shop.name, coordinate: shop.mapItem.placemark.coordinate)
                        .tint(shop.color)
                })
            })
            .mapControls({
                MapUserLocationButton()
                MapCompass()
            })
        }
    }
}

#Preview {
    MapView(isPreview: false, searchTerm: nil, selectedShop: .constant(nil))
}
