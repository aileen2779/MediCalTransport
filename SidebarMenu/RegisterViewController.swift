import UIKit
import FirebaseDatabase
import FirebaseAuth
import NVActivityIndicatorView

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,NVActivityIndicatorViewable {
    
    // Firebase handles
    var ref:DatabaseReference?
    
    var pickerData: [String] = [String]()
    var userPCP:String = ""
    var ipAddress = ""
    
    // Fetch constants
    var myDomain = CONST_DOMAIN

    @IBOutlet weak var phcpPickerView: UIPickerView!
    
    @IBOutlet weak var phoneNumberTextField: CustomTextField!
    @IBOutlet weak var firstNameTextField: CustomTextField!
    @IBOutlet weak var lastNameTextField: CustomTextField!
    @IBOutlet weak var pinTextField: CustomTextField!
    @IBOutlet weak var pinConfirmTextField: CustomTextField!
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var createAnAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = CONST_BGCOLOR

        // Store ip address
        let preferences = UserDefaults.standard
        ipAddress = preferences.object(forKey: "ipAddress") as! String
        
        // firebase reference
        ref = Database.database().reference()
        
        // change navigation title color
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        // change corner radius of button
        phcpPickerView.layer.masksToBounds = true
        phcpPickerView.layer.borderWidth = 2.0
        phcpPickerView.layer.borderColor = UIColor.cyan.cgColor
        phcpPickerView.layer.cornerRadius = 10.0
            
        self.phcpPickerView.delegate = self
        self.phcpPickerView.dataSource = self
        
        pickerData = []
        
        // Populate picker data from firebase
        Database.database().reference().child("pcp/").observeSingleEvent(of: .value, with: { (snapshot) in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in result {
                    self.pickerData.append(snap.value! as! String)
                }
                self.phcpPickerView.reloadAllComponents()
            }
          }
        )
    }
    
    @IBAction func createAnAccountTapped(_ sender: Any) {
        // dismiss the keyboard
        self.view.endEditing(true)
        
        createAnAccountButton.isEnabled = true
        
        // evaluate login and password
        let userPhoneNumber = phoneNumberTextField.text!
        let userFirstName = firstNameTextField.text!
        let userLastName = lastNameTextField.text!
        let userPin = pinTextField.text!
        let userPinConfirm = pinConfirmTextField.text!
        
        // Check for empty fields
        if (userPhoneNumber.isEmpty) {
            animateMe(textField: self.phoneNumberTextField)
            return
        }
        
        if (userFirstName.isEmpty) {
            animateMe(textField: self.firstNameTextField)
            return
        }
        if (userLastName.isEmpty) {
            animateMe(textField: self.lastNameTextField)
            return
        }
        if (userPin.isEmpty) {
            animateMe(textField: self.pinTextField)
            return
        }
        if (userPinConfirm.isEmpty) {
            animateMe(textField: self.pinConfirmTextField)
            return
        }

        if (userPin != userPinConfirm) {
            animateMe(textField: self.pinTextField)
            animateMe(textField: self.pinConfirmTextField)
            return
        }

        //check if telephone number has 10 characters
        if (userPhoneNumber.characters.count != 10) {
            animateMe(textField: self.phoneNumberTextField)
            let alert = UIAlertController(title: "Alert", message: "Telephone Number must include area code", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in })
            self.present(alert, animated: true){}
                        
            return
        }
        
        // assign a default value to PCP
        if (userPCP == "") {
            userPCP = pickerData[0]
        }

        
        //Begin confirm
        let optionMenu = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .actionSheet)
        let scheduleAction = UIAlertAction(title: "Go ahead and create my account", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in

            // show activity activityIndicator
            self.startAnimating(CGSize(width: 40, height: 40), message: "Validating...", type: NVActivityIndicatorType(rawValue: Int(6))!)
            
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                NVActivityIndicatorPresenter.sharedInstance.setMessage("Submitting registration...")
            }


            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.stopAnimating()
            }
            
            // Start auth
            Auth.auth().createUser(withEmail: userPhoneNumber + self.myDomain, password: userPin, completion: { (user, error) in
            
                let uid = user!.uid
                
                // Date time
                let date : Date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/YYYY HH:mm:ss"
                let todaysDate = dateFormatter.string(from: date)
                
                if error != nil{
                    //print("error1: \(error!)")
                    let errorCode = error!.localizedDescription.replacingOccurrences(of: "email address", with: "Patient ID")
                    print("error2: \(errorCode)")

                    firebaseLog(userID: "0000000000", logToSave: ["Message": "\(errorCode)",
                                                                  "FirstName": userFirstName.lowercased(),
                                                                  "LastName": userLastName.lowercased(),
                                                                  "PCP" : self.userPCP,
                                                                  "DateRegistered": todaysDate,
                                                                  "PatientID": userPhoneNumber,
                                                                  "IPAddress" : self.ipAddress
                                                                    ])
                    
                    let alert = UIAlertController(title: "Alert", message: errorCode, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in })
                    self.present(alert, animated: true){}
                    
                    return
                } else {
                    
                    
                    // save to firebase
                    Database.database().reference().child("users/\(uid)/").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let result = snapshot.children.allObjects as? [DataSnapshot] {
                            
                            if (result.isEmpty) {
                                
                                //Begin: Save Trips to Firebase
                                
                                // save patient information
                                var patientRegistration = [:] as [String : Any]
                                patientRegistration = ["UserID" : userPhoneNumber,
                                                       "FirstName" : userFirstName.lowercased(),
                                                       "LastName":  userLastName.lowercased(),
                                                       "PCP":  self.userPCP,
                                                       "DateAdded" : todaysDate,
                                                       "IsActive" : false,
                                                       "DateActivated" : "01/01/1900",
                                                       "Pin" : userPin.hashValue,
                                ]
                                
                                let patientRegistrationUpdates = ["/users/\(uid)/": patientRegistration]
                                self.ref?.updateChildValues(patientRegistrationUpdates)
                                //End: Save Trips to Firebase
                                
                                firebaseLog(userID: uid, logToSave: ["Action" : "register",
                                                                                 "FirstName": userFirstName.lowercased(),
                                                                                 "LastName": userLastName.lowercased(),
                                                                                 "PCP" : self.userPCP,
                                                                                 "DateRegistered": todaysDate,
                                                                                 "IPAddress" : self.ipAddress])
                                
                                delayWithSeconds(0.5) {
                                    self.dismiss(animated: true, completion: nil)
                                }
                                
                                
                            } else {
                                self.displayAlert(title: "Registration Denied!", message: "Phone Number \(userPhoneNumber) already exists")
                                
                            }
                        }
                        
                        
                        
                    })
                    //End database

                    
                }
            })
            // End auth

        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(scheduleAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        //End confirm
        
        //createAnAccountButton.isEnabled = true


    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        userPCP = pickerData[row]
        //print(userPCP)
    }
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 17.0)!,NSForegroundColorAttributeName:UIColor.blue])
        return myTitle
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    
    // Dismiss the keyboard when not editing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

    
    func displayAlert(title: String, message: String) {
        
        let preferences = UserDefaults.standard
        firebaseLog(userID: preferences.object(forKey: "uid") as! String, logToSave: ["UserID": preferences.object(forKey: "userid"), "Message": message])
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertcontroller, animated: true, completion: nil)
        
    }

    
}
