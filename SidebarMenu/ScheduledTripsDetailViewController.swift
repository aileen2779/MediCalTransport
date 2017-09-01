import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase


class ScheduledTripsDetailViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    var ref:DatabaseReference?
    
    
    var requestUsername = "Passenger Location"
    var userType:String = ""
    
    @IBOutlet weak var mapView: MKMapView!
        
    @IBAction func goBackButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    let manager = CLLocationManager()
    
    @IBOutlet weak var pickUpLabel: UILabel!
    @IBOutlet weak var pickUpNowButton: UIButton!
    
    @IBOutlet weak var totalDistanceLabel: UILabel!
    
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
    
    var driverLocation = CLLocation(latitude: 0, longitude: 0)
    var riderLocation = CLLocation(latitude: 0, longitude: 0)
    var toLocation = CLLocation(latitude: 0, longitude: 0)
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations[0]
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        let _:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        //mapView.setRegion(region, animated: true)
        
        //print("Speed: \(location.speed)")
        //print("Altitude: \(location.altitude)")
        print("Latitude: \(location.coordinate.latitude)")
        print("Longitude: \(location.coordinate.longitude)")
        
        //self.mapView.showsUserLocation = true
        
        driverLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let distance = driverLocation.distance(from: riderLocation) / 1000
        let roundedDistance = round(distance * 100) / 100
        pickUpLabel.text = "You are \(roundedDistance) miles away"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Location Manager
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        fromLongitude = location.fromLongitude
        fromLatitude = location.fromLatitude
        toLongitude = location.toLongitude
        toLatitude = location.toLatitude
        
        riderLocation = CLLocation(latitude: fromLatitude, longitude: fromLongitude)
        toLocation = CLLocation(latitude: toLatitude, longitude: toLongitude)
        
        // display total distance label
        displayTotalDistance()
        
        // firebase database init
        ref = Database.database().reference()
        
        // preferences init
        let preferences = UserDefaults.standard
        userType  = preferences.object(forKey: "userType") as! String
        
        if (userType == "passenger") {
            pickUpLabel.isHidden = true
            pickUpNowButton.isHidden = true
        } else {

        }
        
        self.displayMap()
    }

    func displayTotalDistance() {
        let distance = toLocation.distance(from: riderLocation) / 1000
        let roundedDistance = round(distance * 100) / 100
        totalDistanceLabel.text = "Total Distance: \(roundedDistance) miles"
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
