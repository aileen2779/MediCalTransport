import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase


class ScheduledTripsDetailViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    var ref:DatabaseReference?
    
    var requestUsername = "Passenger Location"
    var userType:String = ""
    var uid:String = ""
    var firstName:String = ""
    var lastName:String = ""

    @IBOutlet weak var mapView: MKMapView!
        
    @IBAction func goBackButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    let manager = CLLocationManager()
    
    @IBOutlet weak var pickUpLabel: UILabel!
    @IBOutlet weak var pickUpNowButton: UIButton!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    
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
        
        //print("Driver:\(location.driver)")
        let preferences = UserDefaults.standard
        if (location.driver == ""){
            print("I'm not the driver")
        } else {
            firstName = preferences.object(forKey: "firstName")  as! String
            lastName = preferences.object(forKey: "lastName")  as! String
            if (location.driver.lowercased() == "\(firstName.lowercased()) \(lastName.lowercased())" ) {
                print("I'm the driver!")
                imTheDriver = true
            } else {
                print("I'm not the driver!")
            }
        }
        
        if (!imTheDriver) {
            pickUpNowButton.isHidden = true
        }
        
        riderLocation = CLLocation(latitude: fromLatitude, longitude: fromLongitude)
        toLocation = CLLocation(latitude: toLatitude, longitude: toLongitude)
        
        // display total distance label
        displayTotalDistance()
        
        // firebase database init
        ref = Database.database().reference()
        
        // preferences init
        userType  = preferences.object(forKey: "userType") as! String
        uid   = preferences.object(forKey: "uID") as! String
        
        if (userType == "passenger") {
            //pickUpLabel.isHidden = true
            pickUpNowButton.isHidden = true
        } else {
            
        }
        
        self.displayMap()
    }
    
    @IBAction func pickUpNowTapped(_ sender: Any) {
        
        pickUpLabel.text = "Pick up/Drop off"
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        // Change font of title and message.
        let titleFont = [NSFontAttributeName: UIFont(name: "Arial", size: 0.0)!] //This eliminates the title by setting to 0
        let messageFont = [NSFontAttributeName: UIFont(name: "Avenir-Roman", size: 20.0)!]
        
        let titleAttrString = NSMutableAttributedString(string: "", attributes: titleFont)
        let messageAttrString = NSMutableAttributedString(string: "Do you want to Pick up or Drop off passenger?", attributes: messageFont)
        
        alert.setValue(titleAttrString, forKey: "attributedTitle")
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        let pickupAction = UIAlertAction(title: "Pick Up", style: .destructive, handler: handlePickupPostData)
        let dropOffAction = UIAlertAction(title: "Drop off", style: .destructive, handler: handleDropOffPostData)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeletePostData)
        
        alert.addAction(pickupAction)
        alert.addAction(dropOffAction)
        alert.addAction(cancelAction)
        
        // Support presentation in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func handlePickupPostData(_ alertAction: UIAlertAction!) -> Void {
        
        firebaseLog(userID: uid, logToSave: ["Action" : "pick up", "Driver" : "\(firstName.capitalized) \(lastName.capitalized)", "ToLocation" : "\(toLocation)"])
        
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
    
    func handleDropOffPostData(_ alertAction: UIAlertAction!) -> Void {
        
        firebaseLog(userID: uid, logToSave: ["Action" : "drop off", "Driver" : "\(firstName.capitalized) \(lastName.capitalized)", "ToLocation" : "\(toLocation)" ])
        let requestLocation = CLLocationCoordinate2D(latitude: toLatitude, longitude: toLongitude)
        
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
    func cancelDeletePostData(_ alertAction: UIAlertAction!) {
    }
    
    var location: LocationClass!
    
    var passedValue:[Any] = []
    
    var fromLatitude:Double = 0
    var fromLongitude:Double = 0
    var toLatitude:Double = 0
    var toLongitude:Double = 0
    var driverLatitude:Double = 0
    var driverLongitude:Double = 0
    var driverMovingLongitude:Double = 0
    var driverMovingLatitude:Double = 0
    var imTheDriver:Bool = false
    
    var driverLocation = CLLocation(latitude: 0, longitude: 0)
    var riderLocation = CLLocation(latitude: 0, longitude: 0)
    var toLocation = CLLocation(latitude: 0, longitude: 0)
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {

        let _location = locations[0]
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(_location.coordinate.latitude, _location.coordinate.longitude)
        
        let _:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        
        if (userType == "driver") {
            if imTheDriver {
                //mapView.setRegion(region, animated: true)
                
                //print("Speed: \(location.speed)")
                //print("Altitude: \(location.altitude)")
                //print("Latitude: \(_location.coordinate.latitude)")
                //print("Longitude: \(_location.coordinate.longitude)")
                self.ref?.child("/scheduledtrips/\(location.uid)/\(location.key)").updateChildValues(["DriverLongitude": _location.coordinate.longitude])
                self.ref?.child("/scheduledtrips/\(location.uid)/\(location.key)").updateChildValues(["DriverLatitude": _location.coordinate.latitude])
                self.ref?.child("/scheduledtrips/\(location.uid)/\(location.key)").updateChildValues(["LastAction": "mobile"])
                
                
                //self.mapView.showsUserLocation = true
                
                driverLocation = CLLocation(latitude: _location.coordinate.latitude, longitude: _location.coordinate.longitude)
                
                // store driver longitudes
                driverLatitude = driverLocation.coordinate.latitude
                driverLongitude = driverLocation.coordinate.longitude
                
                let distance = driverLocation.distance(from: riderLocation) / 1000
                let roundedDistance = round(distance * 100) / 100
                
                pickUpLabel.text = "You are \(roundedDistance) miles away"
                
            } else {
                pickUpLabel.text = "Assigned driver: \((location.driver.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? "None" : location.driver.capitalized))"

            }
            
        } else {
            
            Database.database().reference().child("/scheduledtrips/\(location.uid)/\(location.key)").observe(.childChanged, with: { (snapshot) in
               
                if snapshot.key == "DriverLatitude" {
                    self.driverMovingLatitude = snapshot.value as! Double
                }
                
                if snapshot.key == "DriverLongitude" {
                    self.driverMovingLongitude = snapshot.value as! Double
                }
                
                print("\(self.driverMovingLatitude), \(self.driverMovingLongitude)")

                if (self.driverMovingLatitude != 0) {
                    
                    // store driver longitudes
                    self.driverLatitude = self.driverMovingLatitude
                    self.driverLongitude = self.driverMovingLongitude
                    
                    let distance = self.driverLocation.distance(from: self.riderLocation) / 1000
                    let roundedDistance = round(distance * 100) / 100
                    self.pickUpLabel.text = "Your driver is \(roundedDistance) miles away"
                    
                } else {
                    self.pickUpLabel.text = ""
                }

            })
            
            
            
        }
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
