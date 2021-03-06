//
//  MenuController.swift
//  SidebarMenu


import UIKit
import FirebaseAuth

class MenuController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismiss the keyboard

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Logout", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
  
            
            let preferences = UserDefaults.standard
            preferences.removeObject(forKey: "session")
            let ipAddress = preferences.object(forKey: "ipAddress") as! String
            
            //log
            firebaseLog(userID: preferences.object(forKey: "uID") as! String, logToSave: ["Action": "logout", "IPAddress" : ipAddress])

            //signout from firebase
            try! Auth.auth().signOut()
            
            self.dismiss(animated: true, completion: nil)
            
            
        })
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }


}
