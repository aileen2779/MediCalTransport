import UIKit
import FirebaseDatabase

class ScheduledTripsTableViewController: UITableViewController {
    
    @IBOutlet var menuButton:UIBarButtonItem!
    @IBOutlet var extraButton:UIBarButtonItem!
    

    @IBOutlet weak var myTableView: UITableView!
 
    //@IBOutlet weak var fromLabel: UILabel!
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    
    var patientId:String = ""
    
    var postData = [String]()
    
    override func viewDidAppear(_ animated: Bool) {
        //
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // firebase database init
        
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
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        

        // Do any additional setup after loading the view, typically from a nib.
        myTableView.delegate = self
        myTableView.dataSource = self
        
        // Retrieve the posts and listen for changes
        Database.database().reference().child("scheduledtrips/" + patientId).observe(.childAdded, with: { (snapshot) in
    
           if let result = snapshot.children.allObjects as? [DataSnapshot] {
                //print("\(result)")
                var fromString:String = ""
                var toString:String = ""
                var whenString:String = ""
            
            for snap in result {
                    //print("snap.key \(snap.key)")
                    //print("snap.value \(snap.value!)")

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
                self.postData.append("From: \(fromString)\nTo :\(toString)\nWhen: \(whenString)\n")
           } else {
            print("Error retrieving FrB data") // snapshot value is nil
            }
            
            
            
            
            // Try to convert the value of the data to a string
            //let post = snapshot.value as? String
            
            //if let actualPost = post {
                // Append the data to our postData array
            //    self.postData.append(actualPost)
                // Reload the tableview
            //    self.myTableView.reloadData()
            //}
            
            self.myTableView.reloadData()
        })
 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "PostCell")
        //cell?.textLabel?.text = postData[indexPath.row]
        cell?.textLabel?.font =  UIFont.systemFont(ofSize: 14.0)
        cell?.textLabel?.numberOfLines = 4
        cell?.textLabel?.text = postData[indexPath.row]
        return cell!
    }
    

    
}


