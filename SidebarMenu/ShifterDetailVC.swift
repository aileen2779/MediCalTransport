//
//  PokemonDetailVC.swift
//  pokedex3
//

import UIKit
import WebKit

class PokemonDetailVC: UIViewController {
    
    var shifter: ShifterClass!
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 21))

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var mainImg: UIImageView!
    
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var zipLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var emerNameLabel: UILabel!
    @IBOutlet weak var emerNumLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var userIdText: UITextField!
    @IBOutlet weak var phoneText: UITextField!
    @IBOutlet weak var address1Text: UITextField!
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var stateText: UITextField!
    @IBOutlet weak var zipText: UITextField!
    @IBOutlet weak var countryText: UITextField!
    @IBOutlet weak var emerNameText: UITextField!
    @IBOutlet weak var emerNumText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    
    @IBAction func memberNonMember(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.updateUI()
        } else if sender.selectedSegmentIndex == 1{
            self.updateUIWithMember()
        } else {
            waiverForm()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLbl.text = shifter.name.capitalized
        
        let img = UIImage(named: "\(shifter.userId)")
        
        mainImg.image = img

        self.updateUI()
        
    }
    
    
    @IBOutlet weak var webView: UIWebView!
    
    func waiverForm() {
        webView.isHidden = false
        mainImg.isHidden = true
        
        userIdText.isHidden     = true
        phoneText.isHidden      = true
        address1Text.isHidden   = true
        cityText.isHidden       = true
        stateText.isHidden      = true
        zipText.isHidden        = true
        countryText.isHidden    = true
        emerNameText.isHidden   = true
        emerNumText.isHidden    = true
        emailText.isHidden      = true
        
        userIdLabel.isHidden    = true
        phoneLabel.isHidden     = true
        addressLabel.isHidden   = true
        cityLabel.isHidden      = true
        stateLabel.isHidden     = true
        zipLabel.isHidden       = true
        countryLabel.isHidden   = true
        emerNameLabel.isHidden  = true
        emerNumLabel.isHidden   = true
        emailLabel.isHidden     = true

        // replace spaces with %20
        let waiverFile = "\(shifter.waiver_form)".replacingOccurrences(of: " ", with: "%20")
        if waiverFile != "" {
            let urlWaiver  = URL_WAIVER

            let url:URL =  URL(string: "\(urlWaiver)/\(waiverFile)")!
            webView.loadRequest(URLRequest(url: url))
        } else {
            label.isHidden = false
            label.text = ("No waiver found for \(shifter.name)")
            label.center = CGPoint(x: 160, y: 285)
            label.textAlignment = .center
            self.view.addSubview(label)
        }
    }
    
    func updateUIWithMember() {
        
        label.isHidden = true
        webView.isHidden = true
        mainImg.isHidden = false
        
        userIdLabel.isHidden    = false
        phoneLabel.isHidden     = false
        addressLabel.isHidden   = false
        cityLabel.isHidden      = false
        stateLabel.isHidden     = false
        zipLabel.isHidden       = false
        countryLabel.isHidden   = false
        emerNameLabel.isHidden  = false
        emerNumLabel.isHidden   = false
        emailLabel.isHidden     = false
        
        userIdText.isHidden     = false
        phoneText.isHidden      = false
        address1Text.isHidden   = false
        cityText.isHidden       = false
        stateText.isHidden      = false
        zipText.isHidden        = false
        countryText.isHidden    = false
        emerNameText.isHidden   = false
        emerNumText.isHidden    = false
        emailText.isHidden      = false
        
        userIdText.text     = ""
        phoneText.text      = ""
        address1Text.text   = ""
        cityText.text       = ""
        stateText.text      = ""
        zipText.text        = ""
        countryText.isHidden = false
        emerNameText.isHidden = false
        emerNumText.isHidden = false
        emailText.isHidden  = false

        
        userIdText.text     = shifter.userName
        phoneText.text      = shifter.phone1
        address1Text.text   = shifter.address1
        cityText.text       = shifter.city
        stateText.text      = shifter.state
        zipText.text        = shifter.zip
        countryText.text    = shifter.country
        emerNameText.text   = shifter.emergencyName
        emerNumText.text    = shifter.emergencyNum
        emailText.text      = shifter.email
        
        userIdLabel.text    = "User ID   "
        phoneLabel.text     = "Phone     "
        addressLabel.text   = "Address  "
        cityLabel.text      = "City          "
        stateLabel.text     = "State       "
        zipLabel.text       = "  Zip   "
        countryLabel.text   = "Country  "
        emerNameLabel.text  = "Emer. Name "
        emerNumLabel.text   = "Emer. Phone "
        emailLabel.text     = "Email      "
    }

    func updateUI() {
        // hide label
        label.isHidden = true

        let price = Double(shifter.membership_paid)
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = NumberFormatter.Style.currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = NSLocale.current
        let priceString = currencyFormatter.string(from: price! as NSNumber)
        
        // show image
        mainImg.isHidden = false
 
        // hide waiver form
        webView.isHidden = true
            
        userIdText.isHidden     = false
        phoneText.isHidden      = false
        address1Text.isHidden   = false
        cityText.isHidden       = false
        stateText.isHidden      = false
        zipText.isHidden        = false

        userIdText.text     = shifter.membership
        phoneText.text      = priceString
        address1Text.text   = shifter.payment_gateway
        cityText.text       = shifter.membership_status
        stateText.text      = shifter.membership_start
        zipText.text        = shifter.membership_end

        countryText.isHidden = true
        emerNameText.isHidden = true
        emerNumText.isHidden = true
        emailText.isHidden  = true
        
        userIdLabel.isHidden   = false
        phoneLabel.isHidden   = false
        addressLabel.isHidden   = false
        cityLabel.isHidden   = false
        stateLabel.isHidden   = false
        zipLabel.isHidden   = false
        countryLabel.isHidden   = false
        emerNameLabel.isHidden   = false
        emerNumLabel.isHidden   = false
        emailLabel.isHidden   = false
        
        userIdLabel.text    = "Membership    "
        phoneLabel.text     = "Payment          "
        addressLabel.text   = "Payment Type  "
        cityLabel.text      = "Status        "
        stateLabel.text     = "Start  "
        zipLabel.text       = "  Expire  "
        countryLabel.text   = ""
        emerNameLabel.text  = ""
        emerNumLabel.text   = ""
        emailLabel.text     = ""
        
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
