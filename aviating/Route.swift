//
//  Route.swift
//  aviating
//
//  Created by Liza Prokudina on 06.03.2021.
//
import MapKit

class Route {
    var distance: CLLocationDistance
    var numberInArray: Int
    
    init(distance: CLLocationDistance, numberInArray: Int) {
        self.distance = distance
        self.numberInArray = numberInArray
        

    }
}
