import UIKit
import FirebaseDatabase


class ScheduledTripsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var menuButton:UIBarButtonItem!
    @IBOutlet var extraButton:UIBarButtonItem!
    
    var myBGColor:UIColor = UIColor(red:0.49, green:0.73, blue:0.71, alpha:1.0)
    
    @IBOutlet weak var tableView: UITableView!
    
    var deletePostDataIndexPath: IndexPath? = nil
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    
    var patientId:String = ""
    
    var root:String = "scheduledtrips"
    
    var trips: [String: [String]] = [:]

    struct Objects {
        var sectionName : String!
        var sectionObjects : [String]!
    }
    
    var objectArray = [Objects]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // firebase database init
        ref = Database.database().reference()
        
        // preferences init
        let preferences = UserDefaults.standard
        patientId = preferences.object(forKey: "username") as! String
        
        self.title = "Scheduled trips"
        
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            
            revealViewController().rightViewRevealWidth = 200
            extraButton.target = revealViewController()
            extraButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            
            // Disable gesture recognizer so swiping left can be enabled
            // view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        // Retrieve the posts and listen for changes
        Database.database().reference().child( "\(root)/\(patientId)" ).observe(.childAdded, with: { (snapshot) in
            
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                
                let keyString:String = snapshot.key
                var fromString:String = ""
                var toString:String = ""
                var whenString:String = ""
                //var dateAddedString:String = ""
                
                for snap in result {
                    if (snap.key == "pickup") {
                        fromString = snap.value as! String
                    }
                    if (snap.key == "dropoff") {
                        toString = snap.value as! String
                    }
                    if (snap.key == "pickupdate") {
                        whenString = snap.value as! String
                    }
                    //if (snap.key == "dateadded") {
                    //    dateAddedString = snap.value as! String
                    //}
                }
                
                //Append to array
                self.trips = [keyString: ["\(fromString)","\(toString)","\(whenString)"]]
                
                for (key, value) in self.trips {
                    //print("\(key) -> \(value)")
                    self.objectArray.append(Objects(sectionName: key, sectionObjects: value))
                }
                
            } else {
                print("Error retrieving FrB data") // snapshot value is nil
            }
            
            self.tableView.reloadData()
        })
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return objectArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return objectArray[section].sectionObjects.count
        return objectArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath as IndexPath)
        
        // Configure the cell...
        //let id      = objectArray[indexPath.row].sectionName!
        let from    = objectArray[indexPath.row].sectionObjects![0]
        let to      = objectArray[indexPath.row].sectionObjects![1]
        let when    = objectArray[indexPath.row].sectionObjects![2]
        
        cell.textLabel?.font =  UIFont.systemFont(ofSize: 14.0)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = ("From: \(from)\nTo: \(to)\nWhen: \(when)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // set the group title
        return ("Patient ID: \(patientId)")
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = myBGColor
        
        let headerLabel = UILabel(frame: CGRect(x: 50, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont(name: "System", size: 17)
        headerLabel.textColor = UIColor.white
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    // MARK: UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deletePostDataIndexPath = indexPath
            let PostDataToDelete = objectArray[indexPath.row]
            print(PostDataToDelete)
            confirmDelete(PostDataToDelete)
        }
    }
    
    // Delete Confirmation and Handling
    func confirmDelete(_ dataToDelete: Any) {
        let alert = UIAlertController(title: "Cancel Ride", message: "Are you sure you want to Cancel \(dataToDelete)?", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "Yes, I want to cancel This Ride", style: .destructive, handler: handleDeletePostData)
        let CancelAction = UIAlertAction(title: "Go Back", style: .cancel, handler: cancelDeletePostData)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        // Support presentation in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleDeletePostData(_ alertAction: UIAlertAction!) -> Void {
        if let indexPath = deletePostDataIndexPath {
            tableView.beginUpdates()
            
            let id = objectArray[indexPath.row].sectionName!
            
            //print(objectArray[indexPath.row])
            
            // remove from array
            objectArray.remove(at: indexPath.row)
            
            // Note that indexPath is wrapped in an array:  [indexPath]
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            //delete from firebase
            print("scheduledtrips/\(patientId)/\(id)")
            firebaseDelete(childIWantToRemove: "scheduledtrips/\(patientId)/\(id)")
            
            deletePostDataIndexPath = nil
            
            tableView.endUpdates()
        }
    }
    
    func cancelDeletePostData(_ alertAction: UIAlertAction!) {
        deletePostDataIndexPath = nil
    }
    
    func firebaseDelete(childIWantToRemove: String) {
        
        Database.database().reference().child(childIWantToRemove).removeValue { (error, ref) in
            if error != nil {
                print("error \(String(describing: error))")
            }
        }
    }
}

