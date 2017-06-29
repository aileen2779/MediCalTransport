//
//  MainController.swift
//  Created by Gamy Malasarte on 6/6/17.


import UIKit
import LocalAuthentication
import AudioToolbox

class MainController: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var login_button: UIButton!
    @IBOutlet weak var loginTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!

    @IBOutlet weak var loginStackView: UIStackView!
    
    @IBOutlet weak var thumbIdImage: UIImageView!
    @IBOutlet weak var thumbIdButton: UIButton!
    
    var login_session:String = ""
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
         // dismiss the keyboard
        self.view.endEditing(true)
        
        // evaluate login and password
        let userEmail = loginTextField.text!
        let userPassword = passwordTextField.text!
        
        // Check for empty fields
        if (userEmail.isEmpty) {
            animateMe(textField: self.loginTextField)
            //login_button.isEnabled = true
            return
        }
        
        if (userPassword.isEmpty) {
            animateMe(textField: self.passwordTextField)
            //login_button.isEnabled = true
            return
        }

        // hide login stack view and thumb id buttons
        loginStackView.isHidden = true
        thumbIdImage.isHidden = true
        thumbIdButton.isHidden = true
        
        // show activity activityIndicator
        //activityIndicatorStartNoAsync()

        login_now(username:loginTextField.text!, password: passwordTextField.text!)
        
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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // hide the login stack view initially
        loginStackView.isHidden = true
        

        //Init routine to hide keyboard
        self.loginTextField.delegate = self
        self.passwordTextField.delegate = self
        
        // redirect if logged in or not
        let preferences = UserDefaults.standard
        if preferences.object(forKey: "session") != nil {
            // turn on activity monitor for 1 second in async mode
            //activityIndicatorStartAsync()
            
            login_session  = preferences.object(forKey: "session") as! String
            check_session()
        } else {
            loginToDo()

        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // function without arguments that are run from async
    func displayMyAlertMessage() {
        let myAlert =  UIAlertController(title:"Invalid username or password", message: "Please try again", preferredStyle: UIAlertControllerStyle.alert)
        
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

    
    func login_now(username:String, password:String) {
        
        loginTextField.endEditing(true)
        passwordTextField.endEditing(true)
    
        let session_data = "1234567890"
        self.login_session = session_data
    
        let preferences = UserDefaults.standard
        preferences.set(session_data, forKey: "session")
        preferences.set(username, forKey: "username")
        preferences.set(password, forKey: "password")
        preferences.set(true, forKey: "touchIdEnrolled")
        
        DispatchQueue.main.async(execute: self.loginDone)
        
    }

    
    func loginDone() {
        self.performSegue(withIdentifier: "MainControllerVC", sender: self)
    }
    
    
    func animateMe(textField: UITextField) {
        let _thisTextField = textField
        UIView.animate(withDuration: 0.1, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {_thisTextField.center.x += 10 }, completion: nil)
        UIView.animate(withDuration: 0.1, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {_thisTextField.center.x -= 20 }, completion: nil)
        UIView.animate(withDuration: 0.1, delay: 0.2, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {_thisTextField.center.x += 10 }, completion: nil)
    }
    
    func loginToDo() {
        //activityIndicatorStartNoAsync()
        
        let preferences = UserDefaults.standard
        
        if preferences.object(forKey: "username") != nil {
            loginTextField.text = (preferences.object(forKey: "username") as! String)
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
        loginTextField.leftView = UIImageView(image: UIImage(named: "username"))
        

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
                self.loginDone()
            })
        }, failure: { (evaluationError: NSError) -> () in
            switch evaluationError.code {
            case LAError.Code.systemCancel.rawValue:
                print("Authentication cancelled by the system")
                //self.loginToDo()
            case LAError.Code.userCancel.rawValue:
                print("Authentication cancelled by the user")
                //self.loginToDo()
            case LAError.Code.userFallback.rawValue:
                print("User wants to use a password")
                //self.loginToDo()
            case LAError.Code.touchIDNotEnrolled.rawValue:
                print("TouchID not enrolled")
            case LAError.Code.passcodeNotSet.rawValue:
                print("Passcode not set")
                
            default:
                print("Authentication failed")
                //self.loginToDo()
            }
            self.loginToDo()
        })
    }

    func vibrate(howMany: Int) {
        let x = Int(howMany)
        for _ in 1...x {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            //sleep(1)
        }
    }
    
    
    @IBAction func createAccountButtonTapped(_ sender: Any) {
        // hide login stack view and thumb id buttons
        loginStackView.isHidden = !loginStackView.isHidden
        thumbIdImage.isHidden = !thumbIdImage.isHidden
        thumbIdButton.isHidden = thumbIdButton.isHidden
    }
    
    @IBAction func forgotPasswordButtonTapped(_ sender: Any) {
                        
        // hide login stack view and thumb id buttons
        loginStackView.isHidden = !loginStackView.isHidden
        thumbIdImage.isHidden = !thumbIdImage.isHidden
        thumbIdButton.isHidden = thumbIdButton.isHidden
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

}
