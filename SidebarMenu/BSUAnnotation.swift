//
//  BSUAnnotation.swift
//  BSUMaps
//
//  Created by Gamy Malasarte on 5/28/17.
//  Copyright © 2017 Gamy Malasarte. All rights reserved.
//

import MapKit

class BSUAnnotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title:String, subtitle:String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
