import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase


class ScheduledTripsDetailViewController: UIViewController, MKMapViewDelegate {
    var ref:DatabaseReference?
    
    
    var requestUsername = "Passenger Location"
    var userType:String = ""
    
    @IBOutlet weak var mapView: MKMapView!
        
    @IBAction func goBackButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    
    @IBOutlet weak var pickUpLabel: UILabel!
    @IBOutlet weak var pickUpNowButton: UIButton!
    
    @IBAction func pickUpNowTapped(_ sender: Any) {
        
        let requestLocation = CLLocationCoordinate2D(latitude: fromLatitude, longitude: fromLongitude)
        
        let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
        CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let mKPlacemark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: mKPlacemark)
                    mapItem.name = self.requestUsername
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: launchOptions)
                }
            }
        })
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
        
        // firebase database init
        ref = Database.database().reference()
        
        // preferences init
        let preferences = UserDefaults.standard
        userType  = preferences.object(forKey: "userType") as! String
        
        if (userType == "passenger") {
            pickUpLabel.isHidden = true
            pickUpNowButton.isHidden = true
        } else {
            let driverCLLocation = CLLocation(latitude: 36.15911727805614, longitude: -115.1715026681531)
            let riderCLLocation = CLLocation(latitude: 36.0749375, longitude: -115.0132424)
            let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
            let roundedDistance = round(distance * 100) / 100
            print("You are \(roundedDistance) miles away")
            pickUpLabel.text = "You are \(roundedDistance) miles away"
        }

    
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
