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
    var toLatitude:Double = 0
    var toLongitude:Double = 0
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let preferences = UserDefaults.standard
        //let ipAddress = preferences.object(forKey: "ipAddress") as! String
        //let uid = preferences.object(forKey: "uID") as! String
        
        fromLongitude = location.fromLongitude
        fromLatitude = location.fromLatitude
        toLongitude = location.toLongitude
        toLatitude = location.toLatitude
        
        print("\(fromLongitude),\(fromLatitude),\(toLongitude),\(toLatitude)")

        
        // log to firebase
        //firebaseLog(userID: uid, logToSave: ["Action": "trip details",
        //                                     "IPAddress" : ipAddress,
        //                                     "FromLongitude" : fromLongitude,
        //                                     "FromLatitude" : fromLatitude,
        //                                     "ToLatitude" : toLatitude,
        //                                     "ToLongitude" : toLongitude
        //                                    ])
        
        
        self.displayMap()
    }

    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    func displayMap() {
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
         self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: false)
         }
    }
}
