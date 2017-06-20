
//
//  ViewController.swift
//  pokedex3
//
//

import UIKit
import AVFoundation


class DirectoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var extraButton: UIBarButtonItem!

    
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var shifter = [ShifterClass]()
    var filteredShifter = [ShifterClass]()
    var inSearchMode = false
    
    var searchURL = URL_BASE
    
    var refreshControl: UIRefreshControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        revealView()
        
        collection.dataSource = self
        collection.delegate = self
        searchBar.delegate = self
        
        searchBar.returnKeyType = UIReturnKeyType.done
        
        callJSONURL(jsonUrl: searchURL!)
        
        pullToRefresh()
        
    }
    
    func pullToRefresh() {
        // pull to refresh routine
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        collection!.addSubview(refreshControl)
    }
    
    func refresh(sender:AnyObject)
    {
        // Updating your data here...
        callJSONURL(jsonUrl: searchURL!)
        self.collection.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func callJSONURL(jsonUrl: URL) {
        
        
        let url = jsonUrl
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print ("ERROR")
            } else  {
                if let content = data {
                    do {
                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as! [AnyObject]
                        
                        var x = 0
                        //print(myJson)
                        
                        // remove array to prevent duplicates
                        self.shifter.removeAll()
                        
                        repeat {
                            var dict2  = myJson[x] as! [String : String]
                            
                            let userId              = Int(dict2["user_id"]!)!
                            let userName            = String(dict2["user_name"]!)!
                            let address1            = String(dict2["addr1"]!)!
                            let city                = String(dict2["city"]!)!
                            let state               = String(dict2["state"]!)!
                            let zip                 = String(dict2["zip"]!)!
                            let country             = String(dict2["country"]!)!
                            let emergencyName       = String(dict2["emer_contact_name"]!)!
                            let emergencyNum        = String(dict2["emer_contact_number"]!)!
                            let phone1              = String(dict2["phone1"]!)!
                            let email               = String(dict2["email"]!)!
                            let membership          = String(dict2["membership"]!)!
                            
                            let membership_paid     = String(dict2["membership_paid"]!)!
                            let membership_start    = String(dict2["membership_start"]!)!
                            let membership_end      = String(dict2["membership_end"]!)!
                            let membership_status   = String(dict2["membership_status"]!)!
                            let payment_gateway     = String(dict2["payment_gateway"]!)!
                            let waiver_form         = String(dict2["waiver_form"]!)!
                            
                            let name = "\(dict2["first_name"]!.lowercased()) \(dict2["last_name"]!.lowercased())"
                            let shifter = ShifterClass(name: name,
                                                       userId: userId,
                                                       userName: userName,
                                                       address1: address1,
                                                       city: city,
                                                       state: state,
                                                       zip: zip,
                                                       country: country,
                                                       emergencyName: emergencyName,
                                                       emergencyNum: emergencyNum,
                                                       phone1: phone1,
                                                       email: email,
                                                       membership: membership,
                                                       membership_paid: membership_paid,
                                                       membership_start: membership_start,
                                                       membership_end: membership_end,
                                                       membership_status: membership_status,
                                                       payment_gateway: payment_gateway,
                                                       waiver_form: waiver_form)
                            self.shifter.append(shifter)
                            x += 1
                        } while ( x < myJson.count)
                        self.shifter.sort(by: {$0.name < $1.name})
                        
                    } catch {
                        print("done")
                    }
                }
                
                // refresh the collection view
                self.do_refresh();
            }
        }
        task.resume()
    }
    
    // refresh the screen
    func do_refresh()
    {
        DispatchQueue.main.async(execute: {
            self.collection.reloadData()
            return
        })
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokeCell", for: indexPath) as? PokeCell {
            let shiftClassVar: ShifterClass!
            if inSearchMode {
                shiftClassVar = filteredShifter[indexPath.row]
                cell.configureCell(shiftClassVar)
            } else {
                shiftClassVar = shifter[indexPath.row]
                cell.configureCell(shiftClassVar)
            }
            return cell
        } else {
            return UICollectionViewCell()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var shiftClassVar: ShifterClass!
        
        if inSearchMode {
            shiftClassVar = filteredShifter[indexPath.row]
        } else {
            shiftClassVar = shifter[indexPath.row]
        }
        performSegue(withIdentifier: "PokemonDetailVC", sender: shiftClassVar)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if inSearchMode {
            return filteredShifter.count
        }
        return shifter.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 105, height: 105)
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            inSearchMode = false
            collection.reloadData()
            view.endEditing(true)
        } else {
            inSearchMode = true
            let lower = searchBar.text!.lowercased()
            filteredShifter = shifter.filter({$0.name.range(of: lower) != nil})
            collection.reloadData()
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "PokemonDetailVC" {
                if let detailsVC = segue.destination as? PokemonDetailVC {
                    if let shiftClassVar = sender as? ShifterClass {
                        detailsVC.shifter = shiftClassVar
                    }
                }
            }
        }
    
    
    
    func revealView() {
        if revealViewController() != nil {
            revealViewController().rearViewRevealWidth = 230
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            revealViewController().rightViewRevealWidth = 150
            extraButton.target = revealViewController()
            extraButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
            
        }
        
    }
}

