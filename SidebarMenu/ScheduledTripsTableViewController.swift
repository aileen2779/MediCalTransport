import UIKit
import EventKit
import FirebaseDatabase
import Foundation


class ScheduledTripsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var menuButton:UIBarButtonItem!
    @IBOutlet var extraButton:UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    // Placeholder for deleted data
    var deleteUpdatePostDataIndexPath: IndexPath? = nil
    
    var ref:DatabaseReference?

    
    var patientId:String = ""
    var ipAddress:String = ""
    var uid:String = ""
    var userType:String = ""
    var firstName:String = ""
    var lastName:String = ""
    var imTheDriver:Bool = false
    var rideAssignedButImNotTheDriver:Bool = false
    var rideUnAssigned:Bool = false
    
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
        
        // if driver/passenger
        if userType == "driver" {
            displayDriver(filter: "all")
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
        
        cell.textLabel?.font =  UIFont.systemFont(ofSize: 14.0)
        
        cell.textLabel?.textColor = ((driver == "") ? UIColor(red:1.00, green:0.42, blue:0.00, alpha:1.0) : UIColor(red:0.02, green:0.14, blue:0.26, alpha:1.0) )
        
        // Left(1,43)
        var fromSubstring:String = ""
        var toSubstring:String = ""
        let offset = 43
        
        // if length is > 43 then trim and add ...
        if from.characters.count > offset {
            fromSubstring = "\(from[from.startIndex..<from.index(from.startIndex, offsetBy: offset)])..."
        } else {
            fromSubstring = from[from.startIndex..<from.index(from.startIndex, offsetBy: from.characters.count)]
        }
        
        if to.characters.count > offset {
            toSubstring = "\(to[to.startIndex..<to.index(to.startIndex, offsetBy: offset)])..."
        } else {
            toSubstring = to[to.startIndex..<to.index(to.startIndex, offsetBy: to.characters.count)]
        }
        
        cell.textLabel?.numberOfLines = 0
        if (userType == "driver") {
            let myString = ("Passenger: \(passenger)\nFrom: \(fromSubstring)\nTo: \(toSubstring)\nDate: \(when)\nDriver: \(driver)")
            cell.textLabel?.text = myString
        } else {
            let myString = ("From: \(fromSubstring)\nTo: \(toSubstring)\nDate: \(when)\nDriver: \(driver)")
            cell.textLabel?.text = myString
        }
        
        let myCustomSelectionColorView = UIView()
        
        // Change background of selected cell
        myCustomSelectionColorView.backgroundColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1.0)
        cell.selectedBackgroundView = myCustomSelectionColorView
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let locationClassVar: LocationClass!
        locationClassVar = objectArray[indexPath.row]
        
        if (userType == "driver") {

            // find out of i'm the driver or not
            if (locationClassVar.driver.trimmingCharacters(in: .whitespacesAndNewlines)) == "" {
                rideUnAssigned = true
                imTheDriver = false
                print("Ride unassigned!")
            } else {
                rideUnAssigned = false
                if (locationClassVar.driver.lowercased() == "\(firstName.lowercased()) \(lastName.lowercased())") {
                    print("I'm the driver!")
                    rideAssignedButImNotTheDriver = false
                    imTheDriver = true
                } else {
                    rideAssignedButImNotTheDriver = true
                    imTheDriver = false
                    print("Ride Assigned but I'm not the driver")

                }
            }
        
            let option1 = UITableViewRowAction(style: .normal, title: "\u{1F44D}\n End\nPickup") { action, index in
                
                self.deleteUpdatePostDataIndexPath = indexPath
                let PostDataToUpdate = self.objectArray[indexPath.row]
                
                self.confirmEndPickup(PostDataToUpdate)
            }
            option1.backgroundColor = UIColor(red:0.49, green:0.73, blue:0.71, alpha:1.0)

            
            // If I'm the driver Cancel Pickup
            // If unassigned, Confirm pickup
            // If assgined and I'm not the driver. Replace Driver
            let option2 = UITableViewRowAction(style: .normal, title: (rideUnAssigned ? "\u{1F695}\n Confirm\nPickup" : (imTheDriver ? "\u{274C}\n Reject\nPickup" : (rideAssignedButImNotTheDriver ? "\u{267B}\n Replace\nDriver" : "\u{1F44E}\n Cancel\nPickup")))) { action, index in
                
                self.deleteUpdatePostDataIndexPath = indexPath
                let PostDataToUpdate = self.objectArray[indexPath.row]
                
                if self.imTheDriver {
                    self.confirmCancelPickup(PostDataToUpdate)
                } else {
                    
                    (self.rideUnAssigned ? self.confirmPickup(PostDataToUpdate) : (self.imTheDriver ? self.confirmCancelPickup(PostDataToUpdate) : (self.rideAssignedButImNotTheDriver ? self.confirmReplaceDriver(PostDataToUpdate) : self.confirmCancelPickup(PostDataToUpdate))))
                    
                }
            }
            option2.backgroundColor = (rideUnAssigned ? UIColor(red:0.03, green:0.38, blue:0.64, alpha:1.0)
                                                      : (imTheDriver ? UIColor(red:0.45, green:0.06, blue:0.32, alpha:1.0)
                                                                    : (rideAssignedButImNotTheDriver ? UIColor(red:0.03, green:0.43, blue:0.21, alpha:1.0)
                                                                                                    : UIColor(red:1.00, green:0.00, blue:0.24, alpha:1.0))))
            if imTheDriver {
                return [ option1, option2 ]

            } else {
                return [ option2 ]

            }
            
        } else {
            let cancel = UITableViewRowAction(style: .normal, title: "\u{1F5D1}\n Cancel\nride") { action, index in
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
        
        let headerLabel = UILabel(frame: CGRect(x: 50, y: 7, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont(name: "System", size: 17)
        headerLabel.textColor = UIColor.white
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 400.0
        tableView.rowHeight = UITableViewAutomaticDimension
        return UITableViewAutomaticDimension
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
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        // Change font of title and message.
        let titleFont = [NSFontAttributeName: UIFont(name: "Arial", size: 0.0)!] //This eliminates the title by setting to 0
        let messageFont = [NSFontAttributeName: UIFont(name: "Avenir-Roman", size: 20.0)!]
        
        let titleAttrString = NSMutableAttributedString(string: "", attributes: titleFont)
        let messageAttrString = NSMutableAttributedString(string: "Are you sure you want to Cancel this ride?", attributes: messageFont)
        
        alert.setValue(titleAttrString, forKey: "attributedTitle")
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        let DeleteAction = UIAlertAction(title: "Yes, I want to cancel this ride", style: .destructive, handler: handleDeletePostData)
        let CancelAction = UIAlertAction(title: "Go Back", style: .cancel, handler: cancelDeletePostData)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        // Support presentation in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Replace Driver
    func confirmReplaceDriver(_ dataToUpdate: Any) {
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        // Change font of title and message.
        let titleFont = [NSFontAttributeName: UIFont(name: "Arial", size: 0.0)!] //This eliminates the title by setting to 0
        let messageFont = [NSFontAttributeName: UIFont(name: "Avenir-Roman", size: 20.0)!]
        
        let titleAttrString = NSMutableAttributedString(string: "", attributes: titleFont)
        let messageAttrString = NSMutableAttributedString(string: "Are you sure you want to replace the driver", attributes: messageFont)
        
        alert.setValue(titleAttrString, forKey: "attributedTitle")
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        let DeleteAction = UIAlertAction(title: "Yes, I want to replace driver", style: .destructive, handler: handlePickupPostData)
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
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        // Change font of title and message.
        let titleFont = [NSFontAttributeName: UIFont(name: "Arial", size: 0.0)!] //This eliminates the title by setting to 0
        let messageFont = [NSFontAttributeName: UIFont(name: "Avenir-Roman", size: 20.0)!]
        
        let titleAttrString = NSMutableAttributedString(string: "", attributes: titleFont)
        let messageAttrString = NSMutableAttributedString(string: "Are you sure you want to pickup passenger?", attributes: messageFont)
        
        alert.setValue(titleAttrString, forKey: "attributedTitle")
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
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
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        // Change font of title and message.
        let titleFont = [NSFontAttributeName: UIFont(name: "Arial", size: 0.0)!] //This eliminates the title by setting to 0
        let messageFont = [NSFontAttributeName: UIFont(name: "Avenir-Roman", size: 20.0)!]
        
        let titleAttrString = NSMutableAttributedString(string: "", attributes: titleFont)
        let messageAttrString = NSMutableAttributedString(string: "Are you sure you want to cancel pickup?", attributes: messageFont)
        
        alert.setValue(titleAttrString, forKey: "attributedTitle")
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
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
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        // Change font of title and message.
        let titleFont = [NSFontAttributeName: UIFont(name: "Arial", size: 0.0)!] //This eliminates the title by setting to 0
        let messageFont = [NSFontAttributeName: UIFont(name: "Avenir-Roman", size: 20.0)!]
        let titleAttrString = NSMutableAttributedString(string: "", attributes: titleFont)
        
        let messageAttrString = NSMutableAttributedString(string: "Are you sure you want to end pickup?", attributes: messageFont)
        
        alert.setValue(titleAttrString, forKey: "attributedTitle")
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
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
                                                 "Driver" : "\(firstName.capitalized) \(lastName.capitalized)"
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
            self.displayAlert(title: "Pickup Ended", message: "A pickup completion receipt has been sent")
            
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

    
    func displayDriver(filter: String) {

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
            
                // Loop through UID
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
                            if (filter == "all") {
                                self.objectArray.append(location)
                            } else if (filter == "assigned") {
                                if (driver != "") {
                                    
                                    self.objectArray.append(location)
                                }
                            }  else if (filter == "unassigned")  {
                                if (driver == "") {
                                    
                                    self.objectArray.append(location)
                                }
                            
                            } else {
                                //
                            }
                        }
                    }
                    
                    // sorting
                    let sortedObjectArray = self.objectArray.sorted(by: { $0.pickUpDate < $1.pickUpDate })
                    self.objectArray.removeAll()
                    var x = 0
                    while (x < sortedObjectArray.count) {
                        print(sortedObjectArray[x].pickUpDate)
                        let location = LocationClass(key: sortedObjectArray[x].key,
                                                     patientID: self.patientId,
                                                     fromAddress: sortedObjectArray[x].fromAddress,
                                                     fromLongitude: sortedObjectArray[x].fromLongitude,
                                                     fromLatitude: sortedObjectArray[x].fromLatitude,
                                                     toAddress: sortedObjectArray[x].toAddress,
                                                     toLongitude: sortedObjectArray[x].toLongitude,
                                                     toLatitude: sortedObjectArray[x].toLatitude,
                                                     pickUpDate: sortedObjectArray[x].pickUpDate,
                                                     dateAdded: sortedObjectArray[x].dateAdded,
                                                     driver: sortedObjectArray[x].driver,
                                                     passenger: sortedObjectArray[x].passenger,
                                                     uid: sortedObjectArray[x].uid  )
                        self.objectArray.append(location)
                        x += 1
                    }
                    self.tableView.reloadData()
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
                    }
                    self.tableView.reloadData()
                    
                })

                // Watch for deletes
                Database.database().reference().child("\(self.root)/\(snapshot.key)").observe(.childRemoved, with: { (snapshot) in
                    let removedID = snapshot.key
                    
                    var x = 0
                    while (x < self.objectArray.count) {
                        
                        if removedID == self.objectArray[x].key  {
                            print("\(removedID) deleted successfuly")
                            self.objectArray.remove(at: x)
                        
                            // exit
                            x = self.objectArray.count
                        }
                        x += 1
                    }
                })
                self.tableView.reloadData()
            
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
                
                let removedID = snapshot.key 
                var x = 0
                while (x < self.objectArray.count) {
                    
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
    
    @IBOutlet weak var allImage: UIButton!
    @IBOutlet weak var allText: UIButton!
    @IBOutlet weak var assignedImage: UIButton!
    @IBOutlet weak var assignedText: UIButton!
    @IBOutlet weak var unAssignedImage: UIButton!
    @IBOutlet weak var unAssignedText: UIButton!
    
    let grayColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
    
    let assignedColor = UIColor(red:0.01, green:0.01, blue:0.10, alpha:1.0)
    let unAssignedColor = UIColor(red:0.85, green:0.00, blue:0.15, alpha:1.0)
    let allColor = UIColor(red:0.00, green:0.43, blue:0.94, alpha:1.0)
    
    @IBAction func allItemsButtonTapped(_ sender: Any) {

        allText.setTitleColor(allColor, for: .normal)
        assignedText.setTitleColor(grayColor, for: .normal)
        unAssignedText.setTitleColor(grayColor, for: .normal)
        
        allImage.setImage(UIImage(named: "layers.png"), for: .normal)
        assignedImage.setImage(UIImage(named: "unlock_gray.png"), for: .normal)
        unAssignedImage.setImage(UIImage(named: "padlock_gray.png"), for: .normal)
        
        
        objectArray.removeAll()
        tableView.reloadData()
        
        if userType == "driver" {
            displayDriver(filter: "all")
        } else {
            displayPassenger()
        }}

    @IBAction func assignedButtonTapped(_ sender: Any) {

        allText.setTitleColor(grayColor, for: .normal)
        assignedText.setTitleColor(assignedColor, for: .normal)
        unAssignedText.setTitleColor(grayColor, for: .normal)
        
        allImage.setImage(UIImage(named: "layers_gray.png"), for: .normal)
        assignedImage.setImage(UIImage(named: "unlock.png"), for: .normal)
        unAssignedImage.setImage(UIImage(named: "padlock_gray.png"), for: .normal)

        
        objectArray.removeAll()
        tableView.reloadData()
        
        if userType == "driver" {
            displayDriver(filter: "assigned")
        } else {
            displayPassenger()
        }
    }
    
    @IBAction func unAssignedButtonTapped(_ sender: Any) {
        allText.setTitleColor(grayColor, for: .normal)
        assignedText.setTitleColor(grayColor, for: .normal)
        unAssignedText.setTitleColor(unAssignedColor, for: .normal)

        allImage.setImage(UIImage(named: "layers_gray.png"), for: .normal)
        assignedImage.setImage(UIImage(named: "unlock_gray.png"), for: .normal)
        unAssignedImage.setImage(UIImage(named: "padlock.png"), for: .normal)

        objectArray.removeAll()
        tableView.reloadData()
        
        if userType == "driver" {
            displayDriver(filter: "unassigned")
        } else {
            displayPassenger()
        }
    }

}

