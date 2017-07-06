//
//  ScheduledTripsDetailViewController.swift
//  SidebarMenu
//
//  Created by Gamy Malasarte on 7/3/17.
//
//

import UIKit
import MapKit
import CoreLocation


class ScheduledTripsDetailViewController: UIViewController, MKMapViewDelegate {
        @IBOutlet weak var mapView: MKMapView!
        
    @IBAction func goBackButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    var location: LocationClass!
    
    
    var passedValue:[Any] = []
    
    var fromLatitude:Double = 0
    var fromLongitude:Double = 0
    var toLatitude:Double = 0 //36.0749404
    var toLongitude:Double = 0 //-115.01323589999998
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        fromLatitude = location.fromLatitude
        fromLongitude = location.fromLongitude
        toLatitude = location.toLatitude
        toLongitude = location.toLongitude
        print(location.key)
        print("\(fromLatitude)-\(fromLongitude)")
        print("\(toLatitude)-\(toLongitude)")
        
        let fromGeocoder = CLGeocoder()
        fromGeocoder.geocodeAddressString("668 Holland Heights Ave. Las Vegas NV 89123") {
            placemarks, error in
            let fromPlacemark = placemarks!.first
            let fromLatitude = fromPlacemark!.location!.coordinate.latitude
            let fromLongitude = fromPlacemark!.location!.coordinate.longitude
            //print("fromLat: \(String(describing: fromLatitude!)), fromLon: \(String(describing: fromLongitude!))")
        }

        let toGeocoder = CLGeocoder()
        toGeocoder.geocodeAddressString("909 Adobe Flat Dr. Henderson NV 89011") {
            placemarks, error in
            let toPlacemark = placemarks!.first
            let toLatitude = toPlacemark!.location!.coordinate.latitude
            let toLongitude = toPlacemark!.location!.coordinate.longitude
            print("toLat: \(String(describing: toLatitude)), toLon: \(String(describing: toLongitude))")
        }
        
        // 1.
        mapView.delegate = self
        
        // 2.
        let sourceLocation      = CLLocationCoordinate2D(latitude: fromLatitude, longitude: fromLongitude)
        let destinationLocation = CLLocationCoordinate2D(latitude: toLatitude, longitude: toLongitude)
        
        // 3.
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        // 4.
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        // 5.
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "From"
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = "To"
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        // 6.
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        // 7.
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        // 8.
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }

    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        
        return renderer
    }
}
