//
//  ViewController.swift
//  aviating
//
//  Created by Liza Prokudina on 26.02.2021.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var createGraph: UIButton!
    @IBOutlet weak var clear: UIButton!
    @IBOutlet weak var selectDestination: UIButton!
    @IBOutlet weak var createRoute: UIButton!
    @IBOutlet weak var selectStart: UIButton!
    
    let locationManager = CLLocationManager()
    var coordinates = [Point]()
    var tempCoordinates = [CLLocationCoordinate2D]()
    var startPoint: Point?
    var destinationPoint: Point?
    var creatingPoints = true
    var selectingStart = false
    var selectingDestination = false
    var isDashed = true
    var pointCounter = 0
    
    
    //    var sorted = [CLLocationCoordinate2D]()
    //    var tempCoordinates = [Point]()
    //    var tempStartPoint: Point?
    
    @IBAction func createGraphPressed(_ sender: UIButton) {
        selectStart.isEnabled = true
        creatingPoints = false
        for i in 0..<coordinates.count {
            for j in 0..<coordinates.count {
                
                if i < j { continue }
                let point1 = MKMapPoint(coordinates[i].coordinate)
                let point2 = MKMapPoint(coordinates[j].coordinate)
                let distance = point1.distance(to: point2)/1000
                if distance < 5 && distance > 0 {
                    let myPolyLine: MKPolyline = MKPolyline(coordinates: [coordinates[i].coordinate, coordinates[j].coordinate], count: 2)
                    mapView.addOverlay(myPolyLine)
                }
            }
        }
    }
    
    @IBAction func clearPressed(_ sender: UIButton) {
        mapView.removeAnnotations(coordinates)
        if let startPoint = startPoint, let destinationPoint = destinationPoint {
            mapView.removeAnnotation(startPoint)
            mapView.removeAnnotation(destinationPoint)
        }
        
        
        mapView.removeOverlays(mapView.overlays)
        coordinates.removeAll()
        tempCoordinates.removeAll()
        //        sorted.removeAll()
        selectingStart = false
        selectingDestination = false
        creatingPoints = true
        isDashed = true
        pointCounter = 0
        startPoint = nil
        destinationPoint = nil
        
        createGraph.isEnabled = false
        selectStart.isEnabled = false
        selectDestination.isEnabled = false
        createRoute.isEnabled = false
    }
    
    
    @IBAction func selectStartPressed(_ sender: Any) {
        startPoint = nil
        if pointCounter >= 3 {
            selectingStart = true
            addAC(title: "Press i sign after selecting a point", message: "To select a Start Point")
        }
    }
    
    @IBAction func selectDestinationPressed(_ sender: Any) {
        
        if startPoint != nil {
            destinationPoint = nil
            selectingDestination = true
            addAC(title: "Press i sign after selecting a point", message: "To select a Destination Point")
        }
    }
    
    
    @IBAction func createRoutePressed(_ sender: Any) {
        mapView.removeOverlays(mapView.overlays)
        //        findShortestFromStart()
        if pointCounter < 11 {
            findOptimalRoute()
        } else {
            addAC(title: "Too much points!", message:  "Counting can't be done.")
        }
    }
    
    
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        if creatingPoints {
            if sender.state == .ended{
                
                let locationInView = sender.location(in: mapView)
                let tappedCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
                addAnnotation(coordinate: tappedCoordinate)
                pointCounter += 1
                if pointCounter >= 3 {
                    createGraph.isEnabled = true
                }
            }
        } else { return }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        selectStart.isEnabled = false
        selectDestination.isEnabled = false
        createGraph.isEnabled = false
        createRoute.isEnabled = false
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Point else { return nil }
        let identifier = "Point"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
            
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        guard let point = view.annotation as? Point else { return }
        
        if selectingStart && startPoint == nil  {
            startPoint = point
            point.title = "Start Point"
            addAC(title:"Start Point Selected", message: "\(point.coordinate.latitude), \(point.coordinate.latitude)")
            selectingStart = false
            selectDestination.isEnabled = true
            
        } else if selectingDestination && destinationPoint == nil {
            
            destinationPoint = point
            point.title = "Destination Point"
            addAC(title:"Destination Point Selected", message: "\(point.coordinate.latitude), \(point.coordinate.latitude)")
            
            guard let startPoint = startPoint else { return }
            
            while let idx = coordinates.firstIndex(of:startPoint) {
                coordinates.remove(at: idx)
            }
            //            coordinates.insert(startPoint, at: 0)
            guard let destinationPoint = destinationPoint else { return }
            
            while let idx = coordinates.firstIndex(of:destinationPoint) {
                coordinates.remove(at: idx)
            }
            createRoute.isEnabled = true
            //            tempCoordinates = coordinates
            //            tempStartPoint = startPoint
            //            sorted.append(startPoint.coordinate)
            for i in 0..<coordinates.count {
                tempCoordinates.append(coordinates[i].coordinate)
            }
        }
    }
    
    func addAnnotation(coordinate:CLLocationCoordinate2D){
        let point = Point(title: "myPoint", coordinate: coordinate)
        mapView.addAnnotation(point)
        coordinates.append(point)
        
    }
    
    func findOptimalRoute() {
        var allPossibleRoutes = tempCoordinates.permutations
        var totalDistanceInRoute: CLLocationDistance = 0
        var routeDistances = [Route]()
        
        for i in 0..<allPossibleRoutes.count {
            allPossibleRoutes[i].insert(startPoint!.coordinate, at: 0)
            allPossibleRoutes[i].append(destinationPoint!.coordinate)
            
            for j in 0..<allPossibleRoutes[i].count - 1 {
                let point1 = MKMapPoint(allPossibleRoutes[i][j])
                let point2 = MKMapPoint(allPossibleRoutes[i][j+1])
                let distance = point1.distance(to: point2)/1000
                totalDistanceInRoute += distance
            }
            
            routeDistances.append(Route(distance: totalDistanceInRoute, numberInArray: i))
        }
        routeDistances.sort { $0.distance < $1.distance }
        isDashed = false
        let myPolyLine: MKPolyline = MKPolyline(coordinates: allPossibleRoutes[routeDistances[0].numberInArray], count: allPossibleRoutes[routeDistances[0].numberInArray].count)
        
        mapView.addOverlay(myPolyLine)
    }
}

//    func findShortestFromStart() {
//        var shortest: CLLocationDistance = 0
//        var current = 0
//
//        for i in 0..<tempCoordinates.count {
//            if coordinates[i] == tempStartPoint { continue }
//
//            let point1 = MKMapPoint(tempStartPoint!.coordinate)
//            let point2 = MKMapPoint(coordinates[i].coordinate)
//            let distance = point1.distance(to: point2)/1000
//
//            if distance < shortest {
//            shortest = distance
//            current = i
//            }
//        }
//        sorted.append(tempCoordinates[current].coordinate)
//        tempCoordinates.remove(at: current)
//
//        if tempCoordinates.isEmpty {
//            sorted.append(destinationPoint!.coordinate)
//            let myPolyLine: MKPolyline = MKPolyline(coordinates: sorted, count: sorted.count)
//                mapView.addOverlay(myPolyLine)
//            return
//
//        } else {
//            findShortestFromStart()
//        }
//    }







