import UIKit
import FirebaseDatabase
import NVActivityIndicatorView

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,NVActivityIndicatorViewable {
    
    // Firebase handles
    var ref:DatabaseReference?
    
    var pickerData: [String] = [String]()
    var userPCP:String = ""
    
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
        
        pickerData = ["Dr. Ben Calderon",
                      "Dr. Aileen Ramos",
                      "Dr. Butch Edano",
                      "Dr. Topher Rey",
                      "Dr. Sammie D. Dog",
                      "Dr. Joyce Lee"]
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

            //Start database
            Database.database().reference().child("user_access/\(userPhoneNumber)/").observeSingleEvent(of: .value, with: { (snapshot) in

                if let result = snapshot.children.allObjects as? [DataSnapshot] {
                    
                    if (result.isEmpty) {
                        
                        //Begin: Save Trips to Firebase
                        
                        // Date time
                        let date : Date = Date()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM/dd/YYYY HH:mm:ssss"
                        let todaysDate = dateFormatter.string(from: date)
                        
                        
                        // save patient information
                        var patientRegistration = [:] as [String : Any]
                        patientRegistration = ["FirstName" : userFirstName.lowercased(),
                                               "LastName":  userLastName.lowercased(),
                                               "PCP":  self.userPCP,
                                               "DateAdded" : todaysDate
                        ]
                        
                        let patientRegistrationUpdates = ["/users/\(userPhoneNumber)/": patientRegistration]
                        self.ref?.updateChildValues(patientRegistrationUpdates)
                        //End: Save Trips to Firebase
                        
                        // save pin information
                        var pinInformation = [:] as [String : Any]
                        pinInformation = ["DateAdded" : todaysDate,
                                          "IsActive" : true,       // this should be initially set to false pending approval
                                            "Pin" : userPin.hashValue
                        ]
                        
                        let pinInformationUpdates = ["/user_access/\(userPhoneNumber)/": pinInformation]
                        self.ref?.updateChildValues(pinInformationUpdates)
                        //End: Save Trips to Firebase

                        firebaseLog(userID: userPhoneNumber, logToSave: ["Message": "Registration successful"])

                        delayWithSeconds(2) {
                            self.dismiss(animated: true, completion: nil)
                        }
                        
                        
                    } else {
                        self.displayAlert(title: "Registration Denied!", message: "Phone Number \(userPhoneNumber) already exists")
                        
                    }
                }
                
            })
            //End database

            
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

    func validate(email: String) -> Bool {
        let regex: String
        regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
    
    func displayAlert(title: String, message: String) {
        
        let preferences = UserDefaults.standard
        firebaseLog(userID: preferences.object(forKey: "userid") as! String, logToSave: ["UserID": preferences.object(forKey: "userid"), "Message": message])
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertcontroller, animated: true, completion: nil)
        
    }

    
}
