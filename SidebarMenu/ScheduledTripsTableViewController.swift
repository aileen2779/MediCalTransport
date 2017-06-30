import UIKit
import FirebaseDatabase


class ScheduledTripsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var menuButton:UIBarButtonItem!
    @IBOutlet var extraButton:UIBarButtonItem!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    //var postData = ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune", "Team Pluto!"]
    var deletePostDataIndexPath: IndexPath? = nil
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    
    var patientId:String = ""
    
    var postData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // firebase database init
        ref = Database.database().reference()
        
        // preferences init
        let preferences = UserDefaults.standard
        patientId = preferences.object(forKey: "username") as! String
        
        self.title = "Scheduled trips for: " + patientId
        
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            
            revealViewController().rightViewRevealWidth = 200
            extraButton.target = revealViewController()
            extraButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            
            // Disable gesture recognizer so swiping left can be enabled
            // view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        
        // Retrieve the posts and listen for changes
        Database.database().reference().child("scheduledtrips/" + patientId).observe(.childAdded, with: { (snapshot) in
            
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                //print("\(result)")
                var fromString:String = ""
                var toString:String = ""
                var whenString:String = ""
                
                for snap in result {
                    if (snap.key != "dateadded") {
                        if (snap.key == "pickup") {
                            fromString = snap.value as! String
                        }
                        if (snap.key == "dropoff") {
                            toString = snap.value as! String
                        }
                        if (snap.key == "pickupdate") {
                            whenString = snap.value as! String
                        }
                        
                    }
                }
                
                self.postData.append("From: \(fromString)\nTo: \(toString)\nWhen: \(whenString)\n")
                
            } else {
                print("Error retrieving FrB data") // snapshot value is nil
            }
            
            self.tableView.reloadData()
        })
    }
    
    //MARK: UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell")!
        cell.textLabel?.text = postData[indexPath.row]
        cell.textLabel?.font =  UIFont.systemFont(ofSize: 14.0)
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    // MARK: UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deletePostDataIndexPath = indexPath
            let PostDataToDelete = postData[indexPath.row]
            confirmDelete(PostDataToDelete)
        }
    }
    
    // Delete Confirmation and Handling
    func confirmDelete(_ dataToDelete: String) {
        let alert = UIAlertController(title: "Delete Scheduled Ride", message: "Are you sure you want to permanently delete \(dataToDelete)?", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeletePostData)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeletePostData)
        
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
            
            postData.remove(at: indexPath.row)
            
            // Note that indexPath is wrapped in an array:  [indexPath]
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            deletePostDataIndexPath = nil
            
            tableView.endUpdates()
        }
    }
    
    func cancelDeletePostData(_ alertAction: UIAlertAction!) {
        deletePostDataIndexPath = nil
    }
}

