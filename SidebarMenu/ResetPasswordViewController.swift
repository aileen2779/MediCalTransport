import UIKit
import FirebaseDatabase
import FirebaseAuth

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {
    
    var pickerData: [String] = [String]()
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var phoneNumberTextField: CustomTextField!
    @IBOutlet weak var firstNameTextField: CustomTextField!
    
    // Firebase handles
    var ref:DatabaseReference?
    
    var ipAddress:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = CONST_BGCOLOR
        
        // firebase reference
        ref = Database.database().reference()

        
        let preferences = UserDefaults.standard
        ipAddress = preferences.object(forKey: "ipAddress") as! String
        
        // change navigation title color
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        //changeFirebasePassword()
        //fetchUserPin(phoneNumber: "7024654557", firstName:  "aileen")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func resetPasswordButtonTapped(_ sender: Any) {
        
        // dismiss the keyboard
        self.view.endEditing(true)
        
        let phoneNumberPassed = phoneNumberTextField.text!
        let firstNamePassed = firstNameTextField.text!
        
        if (phoneNumberPassed.isEmpty) {
            animateMe(textField: phoneNumberTextField)
            return
        }
        
        if (firstNamePassed.isEmpty) {
            animateMe(textField: firstNameTextField)
            return
        }
        
        //check if telephone number has 10 characters
        if (phoneNumberPassed.characters.count != 10) {
            animateMe(textField: self.phoneNumberTextField)
            let alert = UIAlertController(title: "Alert", message: "Telephone Number must include area code", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in })
            self.present(alert, animated: true){}
            
            return
        }
        
        reesetPassword(phoneNumber: phoneNumberPassed, firstName: firstNamePassed)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    
    // Dismiss the keyboard when not editing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

    func reesetPassword(phoneNumber:String, firstName:String) {
        
        //Start database check
        Auth.auth().signIn(withEmail: "testuser@zundo.com", password: "Welcome01") { (user, error) in
            Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let result = snapshot.children.allObjects as? [DataSnapshot] {
                    //print(result)
                    
                    if (result.isEmpty) {
                        print("Tree is empty")
                        return
                    }
                    
                    for snap in result {
                        //print(snap)
                        if (snap.childSnapshot(forPath: "UserID").value!) as! String == phoneNumber &&
                            (snap.childSnapshot(forPath: "FirstName").value!) as! String == firstName {
                            let pin = snap.childSnapshot(forPath: "Pin").value!
                            print(snap.key)
                            print(pin)
                           
                            
                            Auth.auth().signIn(withEmail: phoneNumber+CONST_DOMAIN, password: pin as! String) { (user, error) in
                                if let error = error {
                                    print(error)
                                } else {
                                    user?.updatePassword(to: "444444") { error in
                                        if error != nil {
                                            // An error occured.
                                            //print(error.localizedDescription)
                                            print("password not changed")
                                        } else {
                                            // Password changed.
                                            print("password changed")
                                        }
                                    }
                                    try! Auth.auth().signOut()
                                }
                            }
                            
                            
                            
                        }
                    }
                    
                }
            })
            //End database
        }
    }

    func reesetPassword1(phoneNumber:String, firstName:String) {
        
        //Start database check
        Database.database().reference().child("users/rxwqtDBWscV6qdrQ606zxweCWXO2/").observeSingleEvent(of: .value, with: { (snapshot) in
            
            var isActive:Bool = false
            var fbFirstName:String = ""
            
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                if (result.isEmpty) {
                    self.displayAlert(title: "Alert!", message: "Phone # \(phoneNumber) does not exist. Cannot reset pin #", userid: CONST_DUMMY_ID)
                } else {
                    for snap in result {
                        if (snap.key == "IsActive") {
                            isActive = snap.value! as! Bool
                        }
                        if (snap.key == "FirstName") {
                            fbFirstName = snap.value! as! String
                        }
                        
                    }
                    
                    if !(isActive) {
                        self.displayAlert(title: "Alert!", message: "Phone # \(phoneNumber) is disabled or has not been activated. Cannot reset pin#",  userid: phoneNumber)
                        print("inactive-\(isActive)")
                        return
                    }
                    
                    if (fbFirstName.lowercased() != firstName.lowercased()) {
                        self.displayAlert(title: "Alert!", message: "First Name \(firstName) is not associated with phone # \(phoneNumber). Cannot reset pin#",  userid: phoneNumber)
                        print("first name does not match")
                        return
                    }
                    
                    // Start: Go ahead and proceed with the reset
                    
                    // Generate temp pin
                    let tempPassword:String = "\(self.generateTempPin())"
                    
                    // Initiate REST API
                    let url:URL = URL(string: CONST_SMS_URL)!
                    let session = URLSession.shared
                    let request = NSMutableURLRequest(url: url)
                    request.httpMethod = "POST"
                    request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
                    
                    let paramString = "phone=\(phoneNumber)&message=Zundo: Your temporary pin # is \(tempPassword). Your pin expires in 5 minutes. Please do not reply&key=\(CONST_SMS_API)"
                    
                    request.httpBody = paramString.data(using: String.Encoding.utf8)
                    
                    let task = session.dataTask(with: request as URLRequest, completionHandler: {
                        (data, response, error) in
                        
                        guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                            print("error")
                            return
                        }
                        
                        let json: Any?
                        
                        do {
                            json = try JSONSerialization.jsonObject(with: data!, options: [])
                        } catch {
                            return
                        }
                        
                        guard let server_response = json as? NSDictionary else {
                            return
                        }
                        
                        print("\(server_response)")
                        
                        let messageSent = "\(server_response["success"]!)"
                        
                        if (messageSent == "0") {
                            print(server_response["error"]!)
                            self.displayAlert(title: "Password Reset Error", message: "Cannot reset pin for \(phoneNumber): \(server_response["error"]!)", userid: CONST_DUMMY_ID)
                        }
                        
                        
                        Auth.auth().signIn(withEmail: phoneNumber+CONST_DOMAIN, password: "222222") { (user, error) in
                            if let error = error {
                                print(error)
                            } else {
                                user?.updatePassword(to: tempPassword) { error in
                                    if let error = error {
                                        // An error occured.
                                        print(error)
                                    } else {
                                        // Password changed.
                                        print("password changed")
                                    }
                                }
                                try! Auth.auth().signOut()
                            }
                        }
                        
                        
                    })
                    
                    task.resume()
                    // End: Go ahead and proceed with the reset
                    
                }
            }
            
        })
        //End database
    }
    
    func displayAlert(title: String, message: String, userid: String) {
        
        // log to firebase
        firebaseLog(userID: userid, logToSave: ["Message": message, "IPAddress" : ipAddress])
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertcontroller, animated: true, completion: nil)
        
    }
    
    func generateTempPin() -> Int {
        // Generate temp pin
        let lower : UInt32 = 100000
        let upper : UInt32 = 999999
        let tempPin = arc4random_uniform(upper - lower) + lower
        print(tempPin)
        return Int(tempPin)
    }
    
    func changeFirebasePassword() {
        //let user = Auth.auth().currentUser
        let newPassword = "222222"
        
        Auth.auth().signIn(withEmail: "7022736420@zundo.com", password: "222222") { (user, error) in
            print("logged in")
            user?.updatePassword(to: newPassword) { error in
                if let error = error {
                    // An error occured.
                    print(error)
                } else {
                    // Password changed.
                    print("password changed")
                }
            }

        }
    }
    func enrypt() {
    

    }
    
    func decrypt() {
        
    }
    
    
  
}
