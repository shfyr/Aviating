//
//  Extensions.swift
//  aviating
//
//  Created by Liza Prokudina on 05.03.2021.
//

import Foundation
import MapKit

extension ViewController: CLLocationManagerDelegate {
    
    func addAC(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
          let myPolyLineRenderer: MKPolylineRenderer = MKPolylineRenderer(overlay: overlay)
          myPolyLineRenderer.lineWidth = 3
          myPolyLineRenderer.strokeColor = UIColor.red
        
        if isDashed {
            myPolyLineRenderer.lineDashPattern = [NSNumber(value: 1),NSNumber(value:5)]
        }
          return myPolyLineRenderer
      }
}

extension CLLocationCoordinate2D: Equatable {}

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}

extension Array {
    func chopped() -> (Element, [Element])? {
          guard let x = self.first else { return nil }
          return (x, Array(self.suffix(from: 1)))
      }
    
    func interleaved(_ element: Element) -> [[Element]] {
         guard let (head, rest) = self.chopped() else { return [[element]] }
         return [[element] + self] + rest.interleaved(element).map { [head] + $0 }
     }
    
    var permutations: [[Element]] {
        guard let (head, rest) = self.chopped() else { return [[]] }
        return rest.permutations.flatMap { $0.interleaved(head) }
    }
}
