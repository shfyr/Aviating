//
//  Point.swift
//  aviating
//
//  Created by Liza Prokudina on 03.03.2021.
//

import UIKit
import MapKit

public class Point: NSObject, MKAnnotation {
    public var title: String?
    public var coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
    
}
