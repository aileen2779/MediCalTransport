//
//  MainController.swift
//  Created by Gamy Malasarte on 6/6/17.

import UIKit
import LocalAuthentication
import FirebaseDatabase
import FirebaseAuth
import NVActivityIndicatorView

class MainController: UIViewController, UITextFieldDelegate, NVActivityIndicatorViewable {

    @IBOutlet weak var login_button: UIButton!
    @IBOutlet weak var loginTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!

    @IBOutlet weak var loginStackView: UIStackView!
    
    @IBOutlet weak var thumbIdImage: UIImageView!
    @IBOutlet weak var thumbIdButton: UIButton!
    
    // Fetch constants
    var myDomain = CONST_DOMAIN
    
    var ipAddress:String = ""
    var login_session:String = ""

    // Firebase handles
    var ref:DatabaseReference?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = CONST_BGCOLOR
        
        // hide the login stack view initially
        loginStackView.isHidden = true
        
        // firebase reference
        ref = Database.database().reference()
        
        //Init routine to hide keyboard
        self.loginTextField.delegate = self
        self.passwordTextField.delegate = self
        
        
        self.getIpAddress(completion: { success in
            if success {
                let preferences = UserDefaults.standard
                
                // Store ip address
                self.ipAddress = preferences.object(forKey: "ipAddress") as! String
                
                // redirect if logged in or not
                if preferences.object(forKey: "session") != nil {
                    self.login_session  = preferences.object(forKey: "session") as! String
                    self.check_session()
                } else {
                    self.loginToDo()
                }
                
            } else {
                //
            }
        })
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // renew ip address
        self.getIpAddress(completion: { success in
            if success {
                let preferences = UserDefaults.standard
                // Store ip address
                self.ipAddress = preferences.object(forKey: "ipAddress") as! String
            } else {
                //
            }
        })
    
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        
         // dismiss the keyboard
        self.view.endEditing(true)
        
        // evaluate login and password
        let userID = loginTextField.text!
        let userPassword = passwordTextField.text!
        
        // Check for empty fields
        if (userID.isEmpty) {
            animateMe(textField: self.loginTextField)
            return
        }
        
        if (userPassword.isEmpty) {
            animateMe(textField: self.passwordTextField)
            return
        }

        // show activity activityIndicator
        let randomNum:UInt32 = arc4random_uniform(30) + 1 // generates random number between (0 and 30) + 1 each representing an animation
        startAnimating(CGSize(width: 40, height: 40), message: "Loading...", type: NVActivityIndicatorType(rawValue: Int(randomNum))!)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            NVActivityIndicatorPresenter.sharedInstance.setMessage("Authenticating...")
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.stopAnimating()
        }
        
        delayWithSeconds(1) {
            self.login_now(userid:self.loginTextField.text!, password: self.passwordTextField.text!)
        }
        
    }
    
    
    @IBAction func touchIdButtonTapped(_ sender: Any) {
        touchAuthenticateUser()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        // check if already logged in after logged out
        // if not logged in, show login and password prompt
        let preferences = UserDefaults.standard
        if preferences.object(forKey: "session") == nil {
            loginToDo()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // function without arguments that are run from async
    func displayMyAlertMessage() {
        let myAlert =  UIAlertController(title:"Invalid Patient ID or password", message: "Please try again", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title:"Ok", style: UIAlertActionStyle.default, handler: nil)
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
        vibrate(howMany: 1)
    }
    
    // Dismiss the keyboard when not editing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

    
    func login_now(userid: String, password: String) {
        
        loginTextField.endEditing(true)
        passwordTextField.endEditing(true)
        
        // Authenticate Firebase
        Auth.auth().signIn(withEmail: userid+myDomain, password: password) { (user, error) in
            
            // Authenticate database
            if error == nil {
                let uid = user!.uid
                //Start database check
                Database.database().reference().child("users/\(uid)/").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    var isActive:Bool = false
                    
                    if let result = snapshot.children.allObjects as? [DataSnapshot] {
                        if (result.isEmpty) {
                            self.displayAlert(title: "Alert!", message: "Patient ID \(userid) does not exist", uid: "0000000000")
                        } else {
                            for snap in result {
                                if (snap.key == "IsActive") {
                                    isActive = snap.value! as! Bool
                                }
                            }
                            
                            if (isActive) {
                                
                                let session_data:Int = userid.hashValue
                                    
                                self.login_session = "\(session_data)"
                                    
                                let preferences = UserDefaults.standard
                                preferences.set(self.login_session, forKey: "session")
                                preferences.set(userid, forKey: "userid")
                                preferences.set(password, forKey: "password")
                                preferences.set(true, forKey: "touchIdEnrolled")
                                preferences.set(false, forKey: "saveLocation")
                                preferences.set(false, forKey: "saveCalendar")
                                preferences.set(self.ipAddress, forKey: "ipAddress")
                                preferences.set(uid, forKey: "uid")
                                
                                //Log action
                                firebaseLog(userID: uid, logToSave: ["Action" : "login", "IPAddress" : self.ipAddress])
                                
                                DispatchQueue.main.async(execute: self.loginDone)
                                
                            } else {
                                self.displayAlert(title: "Alert!", message: "Patient ID \(userid) is disabled or has not been activated",  uid: uid)
                            }
                        }
                    }
                    
                })
                //End database

            } else {
                
                if let errCode = AuthErrorCode(rawValue: (error!._code)) {
                    print("test:\(errCode.rawValue)")
                
                    let preferences = UserDefaults.standard

                    
                    switch (errCode.rawValue) {
                    case 17009:
                        print("The password is invalid or the user does not have a password.")
                        
                        self.passwordTextField.text = ""
                        self.passwordTextField.becomeFirstResponder()
                        preferences.set("", forKey: "password")
                        
                    case 17011:
                        print("There is no user record corresponding to this identifier. The user may have been deleted.")
                        
                        //self.loginTextField.text = ""
                        self.loginTextField.becomeFirstResponder()
                        preferences.set("", forKey: "userid")
                        preferences.set("", forKey: "password")

                    default:
                        print("\(errCode.rawValue): Handle default situation")
                    }
                    
                    preferences.removeObject(forKey: "touchIdEnrolled")
                    
                }
            
                //Tells the user that there is an error and then gets firebase to tell them the error
                self.displayAlert(title: "Alert!", message: "\(userid):\((error?.localizedDescription)!)",  uid: "0000000000")
            }
        }
    }
    
    func loginDone() {
        self.performSegue(withIdentifier: "MainControllerVC", sender: self)
    }
    

    func loginToDo() {
        let preferences = UserDefaults.standard
        
        if preferences.object(forKey: "userid") != nil {
            loginTextField.text = (preferences.object(forKey: "userid") as! String)
            passwordTextField.text = (preferences.object(forKey: "password") as! String)
        }
        
        
        if preferences.object(forKey: "touchIdEnrolled") != nil {
            if ((preferences.object(forKey: "touchIdEnrolled")) != nil) {
                thumbIdImage.isHidden = false
                thumbIdButton.isHidden = false
            } else {
                thumbIdImage.isHidden = true
                thumbIdButton.isHidden = true
            }
        }
        loginStackView.isHidden = false
        //login_button.isEnabled = true

        loginTextField.leftViewMode = UITextFieldViewMode.always
        loginTextField.leftView = UIImageView(image: UIImage(named: "userid"))

        passwordTextField.leftViewMode = UITextFieldViewMode.always
        passwordTextField.leftView = UIImageView(image: UIImage(named: "password"))

    }
    
    func check_session() {
        
        let post_data: NSDictionary = NSMutableDictionary()
        post_data.setValue(login_session, forKey: "session")
        
        let preferences = UserDefaults.standard
        preferences.set(true, forKey: "touchIdEnrolled")
        let uid = preferences.object(forKey: "uid") as! String
        
        //Log action
        firebaseLog(userID: uid, logToSave: ["Action" : "redirect session", "IPAddress" : ipAddress])
        
        DispatchQueue.main.async(execute: loginDone)
    }
    
    func touchAuthenticateUser() {
        
        let touchIDManager = TouchIDManager()
        
        touchIDManager.authenticateUser(success: { () -> () in
                OperationQueue.main.addOperation({ () -> Void in
                    
                //logging
                let preferences = UserDefaults.standard
    
                firebaseLog(userID: preferences.object(forKey: "uid") as! String, logToSave: ["Message": "Touch ID login", "IPAddress": self.ipAddress])
                    
                self.loginDone()
            })
        }, failure: { (evaluationError: NSError) -> () in
            switch evaluationError.code {
            case LAError.Code.systemCancel.rawValue:
                print("Authentication cancelled by the system")
            case LAError.Code.userCancel.rawValue:
                print("Authentication cancelled by the user")
            case LAError.Code.userFallback.rawValue:
                print("User wants to use a password")
            case LAError.Code.touchIDNotEnrolled.rawValue:
                print("TouchID not enrolled")
            case LAError.Code.passcodeNotSet.rawValue:
                print("Passcode not set")
            default:
                print("Authentication failed")
            }
            self.loginToDo()
        })
    }
    

    func displayAlert(title: String, message: String, uid: String) {
        
        // log to firebase
        firebaseLog(userID: uid, logToSave: ["Message": message, "IPAddress": self.ipAddress])
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertcontroller, animated: true, completion: nil)
        
    }

    func getIpAddress (completion: @escaping (Bool) -> () ) {
        
        let preferences = UserDefaults.standard
        
        let url = CONST_IP_URL
        
        if let url = NSURL(string: url) {
            if let data = try? Data(contentsOf: url as URL) {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments)
                    let dict = parsedData as? NSDictionary
                    let _ipAddress = "\(dict!["ip"]!)"
                    preferences.set(_ipAddress, forKey: "ipAddress")
                    completion(true)
                    
                }
                    //else throw an error detailing what went wrong
                catch let error as NSError {
                    print("Details of JSON parsing error:\n \(error.localizedDescription)")
                    let _ipAddress = "0.0.0.0"
                    preferences.set(_ipAddress, forKey: "ipAddress")
                    completion(false)
                }
            }
        }
    }
    
}

