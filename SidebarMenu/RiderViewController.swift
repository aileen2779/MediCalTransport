//
//  RiderViewController.swift


import UIKit
import MapKit
import FirebaseDatabase


class RiderViewController: UIViewController,
                        MKMapViewDelegate,
                        CLLocationManagerDelegate,
                        UITableViewDataSource,
                        UITableViewDelegate,
                        UITextFieldDelegate  {
    
    // Firebase handles
    var ref:DatabaseReference?
    
    
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var extraButton: UIBarButtonItem!
    

    @IBOutlet weak var requestARide: UIButton!
    
    var driverOnTheWay = false
    var locationManager = CLLocationManager()
    var riderRequestActive = true
    var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    
    @IBOutlet var callAnUberButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let optionMenu = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .actionSheet)
        let scheduleAction = UIAlertAction(title: "Schedule this ride", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            //print(self.fromTextField.text!)
            //print(self.toTextField.text!)
            //print(self.whenTextField!)
            //print("Latitude \(self.locationManager.location?.coordinate.latitude)")
    
            
            //let username = Auth.auth().currentUser
            //let userID = Auth.auth().currentUser?.uid
            let username = "gamy316"
            let userID = "gamy316"
            //let preferences = UsegrDefaults.standard
            //username = preferences.object(forKey: "username") as! String
            
            
            // Create new post at /user-posts/$userid/$postid and at
            // /posts/$postid simultaneously
            // [START write_fan_out]
            //let key = (self.ref?.child("ScheduledRides").childByAutoId().key)!
            let datetimekey =  self.whenTextField.text!.replacingOccurrences(of: "/", with: "")

            //print(datetimekey)
            
            var scheduledTrips = [:] as [String : Any]
            
            if self.fromTextField.text == "Current Location" {
                scheduledTrips = ["uid": userID,
                                      "patientid": username,
                                      "fromlocation": self.fromTextField.text!,
                                      "tolocation": self.toTextField.text!,
                                      "pickupdatetime": self.whenTextField.text!,
                                      "currentlongitude": (self.locationManager.location?.coordinate.longitude)!,
                                      "currentlatitude": (self.locationManager.location?.coordinate.latitude)!]
            } else {
                scheduledTrips = ["uid": userID,
                                      "patientid": username,
                                      "fromlocation": self.fromTextField.text!,
                                      "tolocation": self.toTextField.text!,
                                      "pickupdatetime": self.whenTextField.text!]
            }
            
            
            
            let scheduledTripUpdates = ["/scheduledtrips/\(userID)/\(datetimekey)/": scheduledTrips]
            self.ref?.updateChildValues(scheduledTripUpdates)
            // [END write_fan_out]
            
            // from trips
            let savedFromTripsKey = self.fromTextField.text!.hash
            let savedFromTrips = ["from":self.fromTextField.text!]
            let savedFromTripUpdates = ["/savedtrips/\(userID)/from/\(savedFromTripsKey)": savedFromTrips]
            self.ref?.updateChildValues(savedFromTripUpdates)

            // to trips
            let savedToTripsKey = self.toTextField.text!.hash
            let savedToTrips = ["to": self.toTextField.text!]
            let savedToTripUpdates = ["/savedtrips/\(userID)/to/\(savedToTripsKey)": savedToTrips]
            self.ref?.updateChildValues(savedToTripUpdates)
            
            
        })
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(scheduleAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = manager.location?.coordinate {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            print(userLocation)
            if driverOnTheWay == false {
                
                let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.mapView.setRegion(region, animated: true)
                self.mapView.removeAnnotations(self.mapView.annotations)
                //let annotation = MKPointAnnotation()
                //annotation.coordinate = userLocation
                //annotation.title = "Your Location"
                //self.mapView.addAnnotation(annotation)
                
                self.mapView.showsUserLocation = true
            }
        }
        
        if riderRequestActive == true {
            
 
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

    }
    
    // Toggle the tableView visibility when click on textField
    func fromTextFieldActive() {
        values =  [String]()
        
        //var databaseHandle:DatabaseHandle?
        
        // set the firebase reference
        
        Database.database().reference().child("savedtrips/gamy316/from").observeSingleEvent(of: .value, with: { (snapshot) in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    var meanAcc = child.key as! String
                    print(meanAcc)
                }
            }
        })
        
        
        self.values.append("Current Location")
        
        tableView.reloadData()
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.contentSize.height + 100)
        tableView.isHidden = !tableView.isHidden
        editField = "fromTextField"
}

    func toTextFieldActive() {
 
        values = ["546 Martin Luther King Blvd.,\nLas Vegas NV 89000",
                  "909 Adobe Flat Dr.,\nHenderson NV 89011",
                "238 Highgate St.\nHenderson, NV 89012"]
        tableView.reloadData()
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: 200, width: tableView.frame.size.width, height: tableView.contentSize.height + 100)
        tableView.isHidden = !tableView.isHidden
        editField = "toTextField"

    }

    func whenTextFieldActive() {
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
        //cell.textLabel?.font = textField.font
        cell.textLabel?.font =  UIFont(name:"Avenir", size:16)
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

    
    func animateMe(textField: UITextField) {
        
        let _thisTextField = textField
        
        UIView.animate(withDuration: 0.1, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {_thisTextField.center.x += 10 }, completion: nil)
        UIView.animate(withDuration: 0.1, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {_thisTextField.center.x -= 20 }, completion: nil)
        UIView.animate(withDuration: 0.1, delay: 0.2, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {_thisTextField.center.x += 10 }, completion: nil)
    }

    func dropShadow(thisObject: Any) {
        (thisObject as AnyObject).layer.borderColor = UIColor.clear.cgColor
        (thisObject as AnyObject).layer.masksToBounds = false
        (thisObject as AnyObject).layer.shadowColor = UIColor.black.cgColor
        (thisObject as AnyObject).layer.shadowOffset = CGSize.zero
        (thisObject as AnyObject).layer.shadowOpacity = 1
        (thisObject as AnyObject).layer.shadowRadius = 5.0
    }
        
    func displayAlert(title: String, message: String) {
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertcontroller, animated: true, completion: nil)
        
    }
}
