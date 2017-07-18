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
    
    //var login_session:Int = 0
    var login_session:String = ""
    var errorMessage = ""

    // Firebase handles
    var ref:DatabaseReference?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // hide the login stack view initially
        loginStackView.isHidden = true
        
        // firebase reference
        ref = Database.database().reference()
        
        //Init routine to hide keyboard
        self.loginTextField.delegate = self
        self.passwordTextField.delegate = self
        
        // redirect if logged in or not
        let preferences = UserDefaults.standard

        if preferences.object(forKey: "session") != nil {
            login_session  = preferences.object(forKey: "session") as! String
            check_session()
        } else {
            loginToDo()
        }
        
        PhoneAuthProvider.provider().verifyPhoneNumber("+17022736420") { (verificationID, error) in
            if ((error) != nil) {
                // Verification code not sent.
                print(error as Any)
            } else {
                // Successful. -> it's sucessfull here
                print(verificationID as Any)
                UserDefaults.standard.set(verificationID, forKey: "firebase_verification")
                UserDefaults.standard.synchronize()
            }
        }
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

    
    func login_now(userid:String, password:String) {
        
        loginTextField.endEditing(true)
        passwordTextField.endEditing(true)
        
        // Authenticate Firebase
        Auth.auth().signIn(withEmail: userid+myDomain, password: password) { (user, error) in
            
            // Authenticate database
            if error == nil {
                //Start database check
                Database.database().reference().child("user_access/\(userid)/").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    var isActive:Bool = false
                    
                    if let result = snapshot.children.allObjects as? [DataSnapshot] {
                        if (result.isEmpty) {
                            self.displayAlert(title: "Alert!", message: "Patient ID \(userid) does not exist", userid: "0000000000")
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
                                
                                //Log action
                                firebaseLog(userID: userid, logToSave: ["Message": "Login"])
                                
                                DispatchQueue.main.async(execute: self.loginDone)
                                
                            } else {
                                self.displayAlert(title: "Alert!", message: "Patient ID \(userid) is disabled or has not been activated",  userid: userid)
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
                self.displayAlert(title: "Alert!", message: "\(userid):\((error?.localizedDescription)!)",  userid: "0000000000")
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
        
        DispatchQueue.main.async(execute: loginDone)
    }
    
    func touchAuthenticateUser() {
        
        let touchIDManager = TouchIDManager()
        
        touchIDManager.authenticateUser(success: { () -> () in
                OperationQueue.main.addOperation({ () -> Void in
                    
                //logging
                let preferences = UserDefaults.standard
    
                firebaseLog(userID: preferences.object(forKey: "userid") as! String, logToSave: ["Message": "Touch ID login"])
                    
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
    
    func activityIndicatorStartAsync() {
        var activityIndicator = UIActivityIndicatorView()
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 2, y: 2)
        activityIndicator.transform = transform
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            activityIndicator.stopAnimating()
        }
        
        self.view.addSubview(activityIndicator)
    }
    
    func activityIndicatorStartNoAsync() {
        var activityIndicator = UIActivityIndicatorView()
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 2, y: 2)
        activityIndicator.transform = transform
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
    }

    func displayAlert(title: String, message: String, userid: String) {
        
        // log to firebase
        firebaseLog(userID: userid, logToSave: ["Message": message])
        
        let alertcontroller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertcontroller, animated: true, completion: nil)
        
    }
    


}

