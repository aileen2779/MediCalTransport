//
//  ScheduledTripsTableViewController.swift
//  SidebarMenu
//

import UIKit

class ScheduledTripsTableViewController: UITableViewController {

    @IBOutlet var menuButton:UIBarButtonItem!
    @IBOutlet var extraButton:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))

            revealViewController().rightViewRevealWidth = 150
            extraButton.target = revealViewController()
            extraButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))

            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 3
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ScheduledTripsTableViewCell

        // Configure the cell...
        if indexPath.row == 0 {
            cell.fromLabel.text = "668 Holland Heights Ave. Las Vegas, NV 89123"
            cell.toLabel.text = "7266 Summer Grove Ave Las Vegas, NV 89000"
            cell.whenLabel.text = "June 23, 2017 12:00pm"

        } else if indexPath.row == 1 {
            cell.fromLabel.text = "909 Adobe Flat Dr. Henderson, NV 89011"
            cell.toLabel.text = "7266 Summer Grove Ave. Las Vegas, NV 89000"
            cell.whenLabel.text = "July 23, 2017 12:00pm"
            
        } else {
            cell.fromLabel.text = "238 Highgate St. Henderson NV 89012"
            cell.toLabel.text = "7266 Summer Grove Ave Las Vegas, NV 89000"
            cell.whenLabel.text = "August 23, 2017 12:00pm"
            
        }

        return cell
    }
    

}
