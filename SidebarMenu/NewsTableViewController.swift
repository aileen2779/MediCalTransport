//
//  NewsTableViewController.swift
//  SidebarMenu
//
//  Created by Simon Ng on 2/2/15.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit


class NewsTableViewController: UITableViewController {
    @IBOutlet var menuButton:UIBarButtonItem!
    //@IBOutlet var extraButton:UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        if revealViewController() != nil {
//            revealViewController().rearViewRevealWidth = 62
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))

            revealViewController().rightViewRevealWidth = 0
            //extraButton.target = revealViewController()
            //extraButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsTableViewCell

        // Configure the cell...
        if indexPath.row == 0 {
            cell.postImageView.image = UIImage(named: "watchkit-intro")
            cell.postTitleLabel.text = "Calderon Medical Group launches its first mobile app"
            cell.authorLabel.text = "Dr. Benito Calderon"
            cell.authorImageView.image = UIImage(named: "author")

        } else if indexPath.row == 1 {
            cell.postImageView.image = UIImage(named: "custom-segue-featured-1024")
            cell.postTitleLabel.text = "FDA OK's New Drug for Antibiotic-Resistant UTIs"
            cell.authorLabel.text = "WebMD"
            cell.authorImageView.image = UIImage(named: "appcoda-300")
            
        } else {
            cell.postImageView.image = UIImage(named: "webkit-featured")
            cell.postTitleLabel.text = "FDA Recalls Half A Million Pacemakers After Cyber Security Scare"
            cell.authorLabel.text = "WebMD"
            cell.authorImageView.image = UIImage(named: "appcoda-300")
            
        }

        return cell
    }
    


}
