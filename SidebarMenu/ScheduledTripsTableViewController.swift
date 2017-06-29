import UIKit
import FirebaseDatabase

class ScheduledTripsTableViewController: UITableViewController {
    
    @IBOutlet var menuButton:UIBarButtonItem!
    @IBOutlet var extraButton:UIBarButtonItem!
    

    @IBOutlet weak var myTableView: UITableView!
 
    
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    
    var patientId:String = ""
    
    var postData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // Set the firebase reference
        ref = Database.database().reference()
        // Retrieve the posts and listen for changes
        
        //databaseHandle = ref?.child("scheduledtrips/gamy316/").observe(.childAdded, with: { (snapshot) in
        
        Database.database().reference().child("scheduledtrips/" + patientId).observe(.childAdded, with: { (snapshot) in
            
        //Database.database().reference().child("scheduledtrips/gamy316/").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                //print("gamy \(result)")
                
                var myPatientID = ""
                for snap in result {
                    
                    myPatientID = snap.value as! String
                    if (myPatientID != self.patientId) {  // exclude patientid
                        self.postData.append(snap.value as! String)
                    }
                    //if let postDict = snap.value as? Dictionary<String, AnyObject> {
                    //    print(postDict)
                    //    self.postData.append(postDict["pickupdatetime"]! as! String)
                    //    self.postData.append(postDict["pickupfrom"]! as! String)
                    //    self.postData.append(postDict["pickupto"]! as! String)
                    //}
                }
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
        cell?.textLabel?.text = postData[indexPath.row]
        return cell!
    }
    
}


