import UIKit
import EventKit
import FirebaseDatabase
import Foundation


class ScheduledTripsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var menuButton:UIBarButtonItem!
    @IBOutlet var extraButton:UIBarButtonItem!

    
    @IBOutlet weak var tableView: UITableView!
    
    var deleteUpdatePostDataIndexPath: IndexPath? = nil
    
    var ref:DatabaseReference?

    
    var patientId:String = ""
    var ipAddress:String = ""
    var uid:String = ""
    var userType:String = ""
    var firstName:String = ""
    var lastName:String = ""

    
    var root:String = "scheduledtrips"
    
    var trips: [String: [String]] = [:]

    var objectArray = [LocationClass]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // firebase database init
        ref = Database.database().reference()

        // preferences init
        let preferences = UserDefaults.standard
        patientId = preferences.object(forKey: "userID") as! String
        ipAddress = preferences.object(forKey: "ipAddress") as! String
        uid       = preferences.object(forKey: "uID") as! String
        userType  = preferences.object(forKey: "userType") as! String
        firstName  = preferences.object(forKey: "firstName") as! String
        lastName  = preferences.object(forKey: "lastName") as! String
        
        if (userType == "passenger") {
            self.title = "Passenger Console"
        } else {
            self.title = "Driver Console"
        }

        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            
            revealViewController().rightViewRevealWidth = 200
            extraButton.target = revealViewController()
            extraButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            
            // Disable gesture recognizer so swiping left can be enabled
            //view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        
        if userType == "driver" {
            
            displayDriver()
        
        } else { // else driver/passenger
            
            displayPassenger()
            
        } // end if driver/passenger

        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return objectArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath as IndexPath)
        let locationClassVar: LocationClass!
        
        locationClassVar = objectArray[indexPath.row]
        
        // Configure the cell...
        let from    = locationClassVar.fromAddress
        //let fromCoord = ("\(String(format: "%.3f", locationClassVar.fromLatitude)), \(String(format: "%.3f", locationClassVar.fromLongitude))")
        let to      = locationClassVar.toAddress
        //let toCoord = ("\(String(format: "%.3f", locationClassVar.toLatitude)), \(String(format: "%.3f", locationClassVar.toLongitude))")
        let when        = locationClassVar.pickUpDate
        let driver      = locationClassVar.driver
        let passenger   = locationClassVar.passenger
        
        cell.textLabel?.font =  UIFont.systemFont(ofSize: 12.0)
        cell.textLabel?.numberOfLines = 0
        if (userType == "driver") {
            cell.textLabel?.text = ("Passenger: \(passenger)\nFrom: \(from)\nTo: \(to)\nDate: \(when)\nDriver: \(driver)")
        } else {
            cell.textLabel?.text = ("From: \(from)\nTo: \(to)\nDate: \(when)\nDriver: \(driver)")
        }
        return cell
    }
    
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let locationClassVar: LocationClass!
        locationClassVar = objectArray[indexPath.row]
        var myPassenger:Bool = false
        
        if (userType == "driver") {

            // find out of i'm the driver or not
            if (locationClassVar.driver.lowercased() == "\(firstName.lowercased()) \(lastName.lowercased())") {
                print("I'm the driver!")
                myPassenger = true
            } else {
                print("I'm not the driver!")
                myPassenger = false
            }
            
            
            let option1 = UITableViewRowAction(style: .normal, title: "End\nPickup") { action, index in
                print("Option 1 button tapped")
                self.deleteUpdatePostDataIndexPath = indexPath
                let PostDataToUpdate = self.objectArray[indexPath.row]
                
                self.confirmEndPickup(PostDataToUpdate)
            }
            option1.backgroundColor = UIColor(red:0.49, green:0.73, blue:0.71, alpha:1.0)

            let option2 = UITableViewRowAction(style: .normal, title: (myPassenger ? "Cancel\nPickup" : "Confirm\nPickup")) { action, index in
                print("Option 2 button tapped")
                
                self.deleteUpdatePostDataIndexPath = indexPath
                let PostDataToUpdate = self.objectArray[indexPath.row]
                
                if myPassenger {
                    self.confirmCancelPickup(PostDataToUpdate)
                } else {
                    self.confirmPickup(PostDataToUpdate)
                }
            }
            option2.backgroundColor = (myPassenger ? UIColor.red : UIColor(red:0.03, green:0.43, blue:0.21, alpha:1.0))
                
            
//            let option3 = UITableViewRowAction(style: .normal, title: "View\nDetails") { action, index in
//                print("Option 3 button tapped")
//                let locationClassVar: LocationClass!
//                locationClassVar = self.objectArray[indexPath.row]
//                
//                self.performSegue(withIdentifier: "ScheduledTripsVC", sender: locationClassVar!)
//            }
//            option3.backgroundColor = UIColor.blue
            
            return [option1, option2]
            
        } else {
            let cancel = UITableViewRowAction(style: .normal, title: "Cancel\nride") { action, index in
                self.deleteUpdatePostDataIndexPath = indexPath
                let PostDataToDelete = self.objectArray[indexPath.row]
                self.confirmDelete(PostDataToDelete)
            }
            cancel.backgroundColor = UIColor.red
            
            return [cancel]

        }
    }
    
    
    // Header title
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ( (userType == "passenger") ? "Passenger: \(firstName.capitalized) \(lastName.capitalized)" : "Driver: \(firstName.capitalized) \(lastName.capitalized)" )
        //return ("Patient ID: \(patientId)")
    }

    // Header title formatting
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = ((userType == "passenger") ? CONST_BGCOLOR : CONST_BGCOLOR_DRIVER )
        
        
        let headerLabel = UILabel(frame: CGRect(x: 50, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont(name: "System", size: 17)
        headerLabel.textColor = UIColor.white
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let locationClassVar: LocationClass!
        locationClassVar = objectArray[indexPath.row]
        
        performSegue(withIdentifier: "ScheduledTripsVC", sender: locationClassVar!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ScheduledTripsVC" {
            if let detailsVC = segue.destination as? ScheduledTripsDetailViewController {
                if let locationClassVar = sender as? LocationClass {
                    detailsVC.location = locationClassVar
                }
            }
            
        }
    }
 
    // Delete Confirmation and Handling
    func confirmDelete(_ dataToDelete: Any) {
        let alert = UIAlertController(title: "Cancel Ride", message: "Are you sure you want to Cancel this ride?", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "Yes, I want to cancel this ride", style: .destructive, handler: handleDeletePostData)
        let CancelAction = UIAlertAction(title: "Go Back", style: .cancel, handler: cancelDeletePostData)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        // Support presentation in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        
        self.present(alert, animated: true, completion: nil)
    }

    // Pickup Confirmation and Handling
    func confirmPickup(_ dataToUpdate: Any) {
        
        let alert = UIAlertController(title: "Confirm Pick up", message: "Are you sure you want to pickup passenger?", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "Yes, I want to pickup passenger", style: .destructive, handler: handlePickupPostData)
        let CancelAction = UIAlertAction(title: "Go Back", style: .cancel, handler: cancelDeletePostData)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        // Support presentation in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        
        self.present(alert, animated: true, completion: nil)
    }

    // Cancel Pickup Confirmation and Handling
    func confirmCancelPickup(_ dataToUpdate: Any) {
        
        let alert = UIAlertController(title: "Cancel Pickup", message: "Are you sure you want to cancel pickup?", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "Yes, I want to cancel pickup", style: .destructive, handler: handleCancelPickupPostData)
        let CancelAction = UIAlertAction(title: "Go Back", style: .cancel, handler: cancelDeletePostData)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        // Support presentation in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        
        self.present(alert, animated: true, completion: nil)
    }

    // End Pickup Confirmation and Handling
    func confirmEndPickup(_ dataToUpdate: Any) {
        
        let alert = UIAlertController(title: "End Pickup", message: "Are you sure you want to end pickup?", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "Yes, I want to end pickup", style: .destructive, handler: handleEndPickupPostData)
        let CancelAction = UIAlertAction(title: "Go Back", style: .cancel, handler: cancelDeletePostData)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        // Support presentation in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handlePickupPostData(_ alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteUpdatePostDataIndexPath {
            tableView.beginUpdates()
            
            let locationClassVar: LocationClass!
            locationClassVar = objectArray[indexPath.row]
            let parentId = locationClassVar.uid
            let childId = locationClassVar.key
            
            self.ref?.child("\(self.root)/\(parentId)/\(childId)/").updateChildValues(["Driver":"\(firstName.capitalized) \(lastName.capitalized)"])
            
            // Log to firebase
            firebaseLog(userID: uid, logToSave: ["Action" : "pickup ride",
                                                 "PatientID": patientId,
                                                 "FromAddress": locationClassVar.fromAddress,
                                                 "FromLatitude" : locationClassVar.fromLatitude,
                                                 "FromLongitude" : locationClassVar.fromLongitude,
                                                 "ToAddress" : locationClassVar.toAddress,
                                                 "ToLatitude" : locationClassVar.toLatitude,
                                                 "ToLongitude" : locationClassVar.toLongitude,
                                                 "PickUpDate" : locationClassVar.pickUpDate,
                                                 "DateAdded" : locationClassVar.dateAdded,
                                                 "IPAddress" : ipAddress,
                                                 "Driver" : ""
                ])
            
            
            // Display confirmation
            self.displayAlert(title: "Pickup confirmed", message: "A pickup confirmation has been sent.\nThis event has been added to your calendar")
            
            deleteUpdatePostDataIndexPath = nil
            
            tableView.endUpdates()
        }
   
    }

    func handleCancelPickupPostData(_ alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteUpdatePostDataIndexPath {
            tableView.beginUpdates()
            
            let locationClassVar: LocationClass!
            locationClassVar = objectArray[indexPath.row]
            let parentId = locationClassVar.uid
            let childId = locationClassVar.key
            
            self.ref?.child("\(self.root)/\(parentId)/\(childId)/").updateChildValues(["Driver":""])
            
            // Log to firebase
            firebaseLog(userID: uid, logToSave: ["Action" : "pickup ride",
                                                 "PatientID": patientId,
                                                 "FromAddress": locationClassVar.fromAddress,
                                                 "FromLatitude" : locationClassVar.fromLatitude,
                                                 "FromLongitude" : locationClassVar.fromLongitude,
                                                 "ToAddress" : locationClassVar.toAddress,
                                                 "ToLatitude" : locationClassVar.toLatitude,
                                                 "ToLongitude" : locationClassVar.toLongitude,
                                                 "PickUpDate" : locationClassVar.pickUpDate,
                                                 "DateAdded" : locationClassVar.dateAdded,
                                                 "IPAddress" : ipAddress,
                                                 "Driver" : ""
                ])
            
            
            // Display confirmation
            self.displayAlert(title: "Pickup Cancelled", message: "A pickup cancellation has been sent.\nThis event has been removed from your calendar")
            
            deleteUpdatePostDataIndexPath = nil
            
            tableView.endUpdates()
        }
        
    }

    func handleEndPickupPostData(_ alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteUpdatePostDataIndexPath {
            tableView.beginUpdates()
            
            let locationClassVar: LocationClass!
            locationClassVar = objectArray[indexPath.row]
            let parentId = locationClassVar.uid
            let childId = locationClassVar.key
            
            self.ref?.child("\(self.root)/\(parentId)/\(childId)/").updateChildValues(["Completed":true])
            
            // Log to firebase
            firebaseLog(userID: uid, logToSave: ["Action" : "end pickup",
                                                 "PatientID": patientId,
                                                 "FromAddress": locationClassVar.fromAddress,
                                                 "FromLatitude" : locationClassVar.fromLatitude,
                                                 "FromLongitude" : locationClassVar.fromLongitude,
                                                 "ToAddress" : locationClassVar.toAddress,
                                                 "ToLatitude" : locationClassVar.toLatitude,
                                                 "ToLongitude" : locationClassVar.toLongitude,
                                                 "PickUpDate" : locationClassVar.pickUpDate,
                                                 "DateAdded" : locationClassVar.dateAdded,
                                                 "IPAddress" : ipAddress,
                                                 "Driver" : ""
                ])
            
            
            // Display confirmation
            self.displayAlert(title: "Pickup Ended", message: "A pickup completion has been sent.\nThis event has been removed from your calendar")
            
            deleteUpdatePostDataIndexPath = nil
            
            tableView.endUpdates()
        }
        
    }
    
    func handleDeletePostData(_ alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteUpdatePostDataIndexPath {
            tableView.beginUpdates()
            
            let locationClassVar: LocationClass!
            locationClassVar = objectArray[indexPath.row]
            let id = locationClassVar.key

            //delete from firebase
            firebaseDelete(childIWantToRemove: "scheduledtrips/\(uid)/\(id)")
            
            print(patientId)
            // Log to firebase
            
            firebaseLog(userID: uid, logToSave: ["Action" : "cancel ride",
                                                       "PatientID": patientId,
                                                       "FromAddress": locationClassVar.fromAddress,
                                                        "FromLatitude" : locationClassVar.fromLatitude,
                                                        "FromLongitude" : locationClassVar.fromLongitude,
                                                        "ToAddress" : locationClassVar.toAddress,
                                                        "ToLatitude" : locationClassVar.toLatitude,
                                                        "ToLongitude" : locationClassVar.toLongitude,
                                                        "PickUpDate" : locationClassVar.pickUpDate,
                                                        "DateAdded" : locationClassVar.dateAdded,
                                                        "IPAddress" : ipAddress,
                                                        "Driver" : ""
                                                        ])
            
            
            // Remove from calendar
            //let myDate = locationClassVar.pickUpDate
            //let myDateFormatter = DateFormatter()
            //myDateFormatter.dateFormat = "MM/dd/yy h:mm a"
            //myDateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
            
            /* Remove from calendar */
            //let dateString = myDateFormatter.date(from: myDate)
            //print("\(dateString!)-\(event)")
            //self.addEventToCalendar(title: "", description: "", startDate: dateString!, endDate: dateString!)

            
            // Display confirmation
            self.displayAlert(title: "Ride canceled", message: "A ride cancelation has been sent.\nThis event has been removed from your calendar")
            
            deleteUpdatePostDataIndexPath = nil
            
            tableView.endUpdates()
        }
    }
    
    func cancelDeletePostData(_ alertAction: UIAlertAction!) {
        deleteUpdatePostDataIndexPath = nil
    }
    
    func firebaseDelete(childIWantToRemove: String) {
        
        Database.database().reference().child(childIWantToRemove).removeValue { (error, ref) in
            if error != nil {
                print("error \(String(describing: error))")
            }
        }
    }
    
    func displayAlert(title: String, message: String) {
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertcontroller, animated: true, completion: nil)
        
    }

    
    func displayDriver() {

        Database.database().reference().child("\(root)").observe(.childAdded, with: { (snapshot) in
            
           if snapshot.children.allObjects is [DataSnapshot] {
                var keyString:String = ""
                var fromAddress:String = ""
                var fromLongitude:Double = 0.0
                var fromLatitude:Double = 0.0
                var toAddress:String = ""
                var toLongitude:Double = 0.0
                var toLatitude:Double = 0.0
                var pickUpDate:String = ""
                var dateAdded:String = ""
                var rideCompleted:Bool = false
                var driver:String = ""
                var passenger:String = ""
                var passengeruid:String = ""
                passengeruid = snapshot.key
            
                // Watch for new records
                Database.database().reference().child("\(self.root)/\(passengeruid)").observe(.childAdded, with: { (snapshot) in
                    if let postDict = snapshot.value as? Dictionary<String, AnyObject> {

                        keyString = snapshot.key
                        pickUpDate = postDict["PickUpDate"]! as! String
                        fromAddress = postDict["FromAddress"]! as! String
                        fromLatitude = postDict["FromLatitude"]! as! Double
                        fromLongitude = postDict["FromLongitude"]! as! Double
                        toAddress = postDict["ToAddress"]! as! String
                        toLatitude = postDict["ToLatitude"]! as! Double
                        toLongitude = postDict["ToLongitude"]! as! Double
                        rideCompleted = postDict["Completed"]! as! Bool
                        dateAdded = postDict["DateAdded"]! as! String
                        driver = postDict["Driver"]! as! String
                        passenger = postDict["Passenger"]! as! String
                        
                        if !(rideCompleted) {
                            let location = LocationClass(key: keyString,
                                                         patientID: self.patientId,
                                                         fromAddress: fromAddress,
                                                         fromLongitude: fromLongitude,
                                                         fromLatitude: fromLatitude,
                                                         toAddress: toAddress,
                                                         toLongitude: toLongitude,
                                                         toLatitude: toLatitude,
                                                         pickUpDate: pickUpDate,
                                                         dateAdded: dateAdded,
                                                         driver: driver,
                                                         passenger: passenger,
                                                         uid: passengeruid)
                            
                            self.objectArray.append(location)
                        }
                        self.tableView.reloadData()
                    }
                    
                })

                // Watch for updates
                Database.database().reference().child("\(self.root)/\(snapshot.key)").observe(.childChanged, with: { (snapshot) in
                    if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                        keyString = snapshot.key
                        pickUpDate = postDict["PickUpDate"]! as! String
                        fromAddress = postDict["FromAddress"]! as! String
                        fromLatitude = postDict["FromLatitude"]! as! Double
                        fromLongitude = postDict["FromLongitude"]! as! Double
                        toAddress = postDict["ToAddress"]! as! String
                        toLatitude = postDict["ToLatitude"]! as! Double
                        toLongitude = postDict["ToLongitude"]! as! Double
                        rideCompleted = postDict["Completed"]! as! Bool
                        dateAdded = postDict["DateAdded"]! as! String
                        driver = postDict["Driver"]! as! String
                        passenger = postDict["Passenger"]! as! String
                        
                        
                        let removedID = snapshot.key
                        var x = 0
                        while (x < self.objectArray.count) {
                            print("\(removedID) == \(self.objectArray[x].key)")
                            
                            if removedID == self.objectArray[x].key  {
                                print("\(removedID) updated successfuly")
                                self.objectArray.remove(at: x)
                                
                                // exit
                                x = self.objectArray.count
                            }
                            x += 1
                        }
                        
                        if !(rideCompleted) {
                            let location = LocationClass(key: keyString,
                                                         patientID: self.patientId,
                                                         fromAddress: fromAddress,
                                                         fromLongitude: fromLongitude,
                                                         fromLatitude: fromLatitude,
                                                         toAddress: toAddress,
                                                         toLongitude: toLongitude,
                                                         toLatitude: toLatitude,
                                                         pickUpDate: pickUpDate,
                                                         dateAdded: dateAdded,
                                                         driver: driver,
                                                         passenger: passenger,
                                                         uid: passengeruid)
                            
                            self.objectArray.append(location)
                        }
                        self.tableView.reloadData()
                    }
                    
                })

                // Watch for deletes
                Database.database().reference().child("\(self.root)/\(snapshot.key)").observe(.childRemoved, with: { (snapshot) in
                    let removedID = snapshot.key
                    
                    var x = 0
                    while (x < self.objectArray.count) {
                        print("\(removedID) == \(self.objectArray[x].key)")
                        
                        if removedID == self.objectArray[x].key  {
                            print("\(removedID) deleted successfuly")
                            self.objectArray.remove(at: x)
                        
                            // exit
                            x = self.objectArray.count
                        }
                        x += 1
                    }
                    self.tableView.reloadData()
                })
            
            
            
            
            } else {
                print("Error retrieving Firebase data") // snapshot value is nil
            }
        })
        
    }

    func displayPassenger() {
        var keyString:String = ""
        var patientID:String = ""
        var fromAddress:String = ""
        var fromLongitude:Double = 0.0
        var fromLatitude:Double = 0.0
        var toAddress:String = ""
        var toLongitude:Double = 0.0
        var toLatitude:Double = 0.0
        var pickUpDate:String = ""
        var dateAdded:String = ""
        var rideCompleted:Bool = false
        var driver:String = ""
        var passenger:String = ""
        
        // Retrieve the posts and listen for changes
        Database.database().reference().child( "\(root)/\(uid)" ).observe(.childAdded, with: { (snapshot) in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {

                keyString = snapshot.key
                
                for snap in result {
                    if (snap.key == "PatientID") {
                        patientID = snap.value as! String
                    }
                    if (snap.key == "FromAddress") {
                        fromAddress = snap.value as! String
                    }
                    if (snap.key == "FromLongitude") {
                        fromLongitude = snap.value as! Double
                        
                    }
                    if (snap.key == "FromLatitude") {
                        fromLatitude = snap.value as! Double
                    }
                    
                    if (snap.key == "ToAddress") {
                        toAddress = snap.value as! String
                    }
                    if (snap.key == "ToLongitude") {
                        toLongitude = snap.value as! Double
                        
                    }
                    if (snap.key == "ToLatitude") {
                        toLatitude = snap.value as! Double
                    }
                    if (snap.key == "PickUpDate") {
                        pickUpDate = snap.value as! String
                    }
                    if (snap.key == "DateAdded") {
                        dateAdded = snap.value as! String
                    }
                    if (snap.key == "Completed") {
                        rideCompleted = snap.value as! Bool
                    }
                    if (snap.key == "Driver") {
                        driver = snap.value as! String
                    }
                    if (snap.key == "Passenger") {
                        passenger = snap.value as! String
                    }
                }
                
                if !(rideCompleted) {
                    let location = LocationClass(key: keyString,
                                                 patientID: patientID,
                                                 fromAddress: fromAddress,
                                                 fromLongitude: fromLongitude,
                                                 fromLatitude: fromLatitude,
                                                 toAddress: toAddress,
                                                 toLongitude: toLongitude,
                                                 toLatitude: toLatitude,
                                                 pickUpDate: pickUpDate,
                                                 dateAdded: dateAdded,
                                                 driver: driver,
                                                 passenger: passenger,
                                                 uid: self.uid)
                    
                    self.objectArray.append(location)
                }
            } else {
                print("Error retrieving Firebase data") // snapshot value is nil
            }
            self.tableView.reloadData()
        })
        
        // Watch for updates
        Database.database().reference().child( "\(root)/\(uid)" ).observe(.childChanged, with: { (snapshot) in
            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                keyString = snapshot.key
                pickUpDate = postDict["PickUpDate"]! as! String
                fromAddress = postDict["FromAddress"]! as! String
                fromLatitude = postDict["FromLatitude"]! as! Double
                fromLongitude = postDict["FromLongitude"]! as! Double
                toAddress = postDict["ToAddress"]! as! String
                toLatitude = postDict["ToLatitude"]! as! Double
                toLongitude = postDict["ToLongitude"]! as! Double
                rideCompleted = postDict["Completed"]! as! Bool
                dateAdded = postDict["DateAdded"]! as! String
                driver = postDict["Driver"]! as! String
                passenger = postDict["Passenger"]! as! String
                
                
                let removedID = snapshot.key
                var x = 0
                while (x < self.objectArray.count) {
                    print("\(removedID) == \(self.objectArray[x].key)")
                    
                    if removedID == self.objectArray[x].key  {
                        print("\(removedID) updated successfuly")
                        self.objectArray.remove(at: x)
                        
                        // exit
                        x = self.objectArray.count
                    }
                    x += 1
                }
                
                if !(rideCompleted) {
                    let location = LocationClass(key: keyString,
                                                 patientID: self.patientId,
                                                 fromAddress: fromAddress,
                                                 fromLongitude: fromLongitude,
                                                 fromLatitude: fromLatitude,
                                                 toAddress: toAddress,
                                                 toLongitude: toLongitude,
                                                 toLatitude: toLatitude,
                                                 pickUpDate: pickUpDate,
                                                 dateAdded: dateAdded,
                                                 driver: driver,
                                                 passenger: passenger,
                                                 uid: self.uid)
                    
                    self.objectArray.append(location)
                }
                self.tableView.reloadData()
            }
            
        })
        
        
        
        // Retrieve the posts and listen for changes
        Database.database().reference().child( "\(root)/\(uid)" ).observe(.childRemoved, with: { (snapshot) in
            if snapshot.children.allObjects is [DataSnapshot] {
                print("test")
                let removedID = snapshot.key // "01012011 11:59 PM"
                var x = 0
                while (x < self.objectArray.count) {
                    print("\(removedID) - \(self.objectArray[x].key)")
                    if removedID == self.objectArray[x].key  {
                        print("\(removedID) deleted successfuly")
                        self.objectArray.remove(at: x)
                        
                        // exit
                        x = self.objectArray.count
                    }
                    x += 1
                }
                
            } else {
                print("Error retrieving Firebase data") // snapshot value is nil
            }
            
            self.tableView.reloadData()
        })

    }
}

