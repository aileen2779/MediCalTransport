//
//  RiderViewController.swift


import UIKit
import MapKit
import EventKit
import FirebaseDatabase
import Foundation
import CoreLocation


class RiderViewController: UIViewController,
                        MKMapViewDelegate,
                        CLLocationManagerDelegate,
                        UITableViewDataSource,
                        UITableViewDelegate,
                        UITextFieldDelegate  {
    
    // Firebase handles
    var ref:DatabaseReference?
    
    // Navigation bars
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var extraButton: UIBarButtonItem!
    
    // UIButton
    @IBOutlet weak var requestARide: UIButton!
    
    //var driverOnTheWay = false
    var locationManager = CLLocationManager()
    var riderRequestActive = true
    var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var patientId:String = ""
    
    let fromString = "FromAddress"
    let toString = "ToAddress"
    let whenString = "PickUpDate"
    
    @IBOutlet var callAnUberButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let preferences = UserDefaults.standard
        patientId = preferences.object(forKey: "userid") as! String

        // add shadow
        dropShadow(thisObject: requestARide)
        dropShadow(thisObject: fromTextField)
        dropShadow(thisObject: toTextField)
        dropShadow(thisObject: whenTextField)

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
 
        // firebase reference
        ref = Database.database().reference()
        
        // reveal controller
        if revealViewController() != nil {

            //revealViewController().rearViewRevealWidth = 150
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            revealViewController().rightViewRevealWidth = 200
            extraButton.target = revealViewController()
            extraButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        // Textfield
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fromTextField.delegate = self
        toTextField.delegate = self
        whenTextField.delegate = self
        
        tableView.isHidden = true
        
        // Manage tableView visibility via TouchDown in textField
        fromTextField.addTarget(self, action: #selector(fromTextFieldActive), for: UIControlEvents.touchDown)
        toTextField.addTarget(self, action: #selector(toTextFieldActive), for: UIControlEvents.touchDown)
        whenTextField.addTarget(self, action: #selector(whenTextFieldActive), for: UIControlEvents.touchDown)
    }
    
    @IBAction func callAnUber(_ sender: AnyObject) {
        
            // Check for empty fields
            if (fromTextField.text!.isEmpty) {
                animateMe(textField: fromTextField)
                return
            } else if (toTextField.text!.isEmpty){
                animateMe(textField: toTextField)
                return
            } else if (whenTextField.text!.isEmpty){
                animateMe(textField: whenTextField)
                return
            } else {
                //
            }
        
        //Begin confirm
        let optionMenu = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .actionSheet)
        let scheduleAction = UIAlertAction(title: "Schedule this ride", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
        
            /* start confirm */
            
            // Date time
            let date : Date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/YYYY HH:mm:ssss"
            let todaysDate = dateFormatter.string(from: date)
            
            let fromLocation = self.fromTextField.text!
            let toLocation = self.toTextField.text!
            let whenPickup = self.whenTextField.text!
            let patientId = self.patientId
            
            let datetimekey =  whenPickup.replacingOccurrences(of: "/", with: "")

            var scheduledTrips = [:] as [String : Any]
            let fromLongitude = (self.locationManager.location?.coordinate.longitude)!
            let fromLatitude = (self.locationManager.location?.coordinate.latitude)!
            
            var toLongitude = 0.0
            var toLatitude = 0.0
            
            let Geocoder = CLGeocoder()
            Geocoder.geocodeAddressString(toLocation) {
                placemarks, error in
                let toPlacemark = placemarks!.first
                toLatitude = toPlacemark!.location!.coordinate.latitude
                toLongitude = toPlacemark!.location!.coordinate.longitude
            
                print(toLatitude)
                print(toLongitude)
            
                // if current location, then use coordinates, else use from address
                scheduledTrips = ["\(self.fromString)": fromLocation,
                              "FromLongitude" : fromLongitude,
                              "FromLatitude":  fromLatitude,
                              "\(self.toString)": toLocation,
                              "ToLongitude" : toLongitude,
                              "ToLatitude":  toLatitude,
                              "\(self.whenString)": whenPickup,
                              "DateAdded" : todaysDate]
            
                let scheduledTripUpdates = ["/scheduledtrips/\(patientId)/\(datetimekey)/": scheduledTrips]
            
                self.ref?.updateChildValues(scheduledTripUpdates)
                // [END write_fan_out]
            
                // save from trips to firebase
                if self.fromTextField.text != "Current Location" {
                    let savedFromTripsKey = fromLocation.hash
                    let savedFromTrips = ["\(self.fromString)": fromLocation]
                    let savedFromTripUpdates = ["/savedtrips/\(patientId)/\(self.fromString)/\(savedFromTripsKey)": savedFromTrips]
                    self.ref?.updateChildValues(savedFromTripUpdates)
                }
            
                // save to trips to firebase
                let savedToTripsKey = toLocation.hash
                let savedToTrips = ["\(self.toString)": toLocation]
                let savedToTripUpdates = ["/savedtrips/\(patientId)/\(self.toString)/\(savedToTripsKey)": savedToTrips]
                self.ref?.updateChildValues(savedToTripUpdates)
                /* end confirm */
                
                // stop transmitting location
                self.locationManager.stopUpdatingLocation()
            
                // Add to calendar
                let myDate = whenPickup
                let myDateFormatter = DateFormatter()
                myDateFormatter.dateFormat = "MM/dd/yy h:mm a"
                myDateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
            
                let dateString = myDateFormatter.date(from: myDate)
                //print("\(dateString!) - \(whenPickup) - \(TimeZone.current.secondsFromGMT())")
            
                self.addEventToCalendar(title: "Ride Schedule to \(toLocation)", description: "\(scheduledTripUpdates)", startDate: dateString!, endDate: dateString!)
                // End add to calendar
            
                // Display confirmation
                self.displayAlert(title: "Success", message: "A ride request has been submitted for \(whenPickup) from \(fromLocation) to \(toLocation).\nThe event has been added to your calendar")
            
                // clear textfields
                self.fromTextField.text = ""
                self.toTextField.text = ""
                self.whenTextField.text = ""
            
                //segue into Scheduled Trips VC
                //self.present( UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ScheduledTripsVC") as UIViewController, animated: true, completion: nil)
            }
        })
        //
    
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(scheduleAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
        //End confirm
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = manager.location?.coordinate {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            //print(userLocation)
            let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
            self.mapView.setRegion(region, animated: false )
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.showsUserLocation = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // The sample values
    var values = [""]

    let cellReuseIdentifier = "cell"
    var editField = ""
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    // Using simple subclass to prevent the copy/paste menu
    // This is optional, and a given app may want a standard UITextField
    
    
    //@IBOutlet weak var fromTextField: NoCopyPasteUITextField!
    @IBOutlet weak var fromTextField: CustomTextField!
    @IBOutlet weak var toTextField: CustomTextField!
    @IBOutlet weak var whenTextField: CustomTextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func fromTextFieldChanged(_ sender: Any) {
        tableView.isHidden = true

    }
    @IBAction func toTextFieldChanged(_ sender: Any) {
        tableView.isHidden = true

    }
    
    @IBAction func whenTextFieldChanged(_ sender: Any) {
        tableView.isHidden = true
    }
    
    
    override func viewDidLayoutSubviews()
    {
        // Assumption is we're supporting a small maximum number of entries
        // so will set height constraint to content size
        // Alternatively can set to another size, such as using row heights and setting frame
        heightConstraint.constant = tableView.contentSize.height
    }

    
    // Manage keyboard and tableView visibility
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch:UITouch = touches.first else
        {
            return;
        }
        if touch.view != tableView
        {
            fromTextField.endEditing(true)
            toTextField.endEditing(true)
            whenTextField.endEditing(true)
            tableView.isHidden = true
        }

        whenTextField.isEnabled = true
        view.endEditing(true)
        
    }

    
    // Toggle the tableView visibility when click on textField
    func fromTextFieldActive() {
        
        values = [String]()
        values = ["Current Location"]
        
        Database.database().reference().child("savedtrips/" + patientId + "/" + fromString).observeSingleEvent(of: .value, with: { (snapshot) in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
            for snap in result {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        self.values.append(postDict["\(self.fromString)"]! as! String)
                    }
                }
            }
            
            
            //self.values.sort()
            self.tableView.reloadData()
            self.tableView.frame = CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y, width: self.tableView.frame.size.width, height: self.tableView.contentSize.height + 100)
            self.tableView.isHidden = !self.tableView.isHidden
        })
        
        editField = "fromTextField"
}

    func toTextFieldActive() {
 
        self.values.removeAll()

        Database.database().reference().child("savedtrips/" + patientId + "/" + toString).observeSingleEvent(of: .value, with: { (snapshot) in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in result {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        self.values.append(postDict["\(self.toString)"]! as! String)
                    }
                }
            }
            
            self.tableView.reloadData()
            self.tableView.frame = CGRect(x: self.tableView.frame.origin.x, y: 200, width: self.tableView.frame.size.width, height: self.tableView.contentSize.height + 100)
            self.tableView.isHidden = !self.tableView.isHidden
        })
        
        editField = "toTextField"
    }

    func whenTextFieldActive() {
        whenTextField.resignFirstResponder()
        showDatePicker()
        whenTextField.isEnabled = false
    }

    // MARK: UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        // TODO: Your app can do something when textField finishes editing
        print("The textField ended editing. Do something based on app requirements.")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        fromTextField.resignFirstResponder()
        toTextField.resignFirstResponder()
        whenTextField.resignFirstResponder()
        return true
    }

    func showDatePicker() {
        let min = Date()
        let max = Date().addingTimeInterval(60 * 60 * 24 * 30)
        let picker = DateTimePicker.show(minimumDate: min, maximumDate: max)
        picker.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker.darkColor = UIColor.darkGray
        picker.doneButtonTitle = " Pick This date"
        picker.todayButtonTitle = "Today"
        picker.is12HourFormat = true
        picker.dateFormat = "MM/dd/YYYY hh:mm aa"
        //        picker.isDatePickerOnly = true
        picker.completionHandler = { date in
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/YYYY hh:mm aa"
            
            self.whenTextField.text = formatter.string(from: date)
            self.whenTextField.isEnabled = true
            return
        }
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count;
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!
        // Set text from the data model
        cell.textLabel?.text = values[indexPath.row]
        cell.textLabel?.font =  UIFont(name:"Avenir", size:14)
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel?.numberOfLines = 3
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
        
        if (editField == "fromTextField") {
            fromTextField.text = values[indexPath.row].replacingOccurrences(of: "Home:", with: "")
        } else if (editField == "toTextField") {
            toTextField.text = values[indexPath.row]
        } else {
            print(editField)
        }
        
        tableView.isHidden = true
        fromTextField.endEditing(true)
        toTextField.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }




        
    func displayAlert(title: String, message: String) {
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertcontroller, animated: true, completion: nil)
        
    }

    func addEventToCalendar(title: String, description: String?, startDate: Date, endDate: Date, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                event.notes = description
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let e as NSError {
                    completion?(false, e)
                    return
                }
                completion?(true, nil)
            } else {
                completion?(false, error as NSError?)
            }
        })
    }

}

