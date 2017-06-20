//
//  MainController.swift
//  702Shifters
//
//  Created by Gamy Malasarte on 6/6/17.
//  Copyright © 2017 Jonny B. All rights reserved.
//

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
    
    let url  = URL_AUTH
    
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
        activityIndicatorStartNoAsync()
        
        // disable login button to prevent performing segue twice
        //login_button.isEnabled = false

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
            activityIndicatorStartAsync()
            
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
        let post_data: NSDictionary = NSMutableDictionary()
        
        post_data.setValue(username, forKey: "username")
        post_data.setValue(password, forKey: "password")
        
        let url:URL = URL(string: self.url)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        var paramString = ""
        
        for (key, value) in post_data {
            paramString = paramString + (key as! String) + "=" + (value as! String) + "&"
        }
        
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
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
            
           //print(server_response)
            
            // If data_block is empty, session id would be missing
            if let data_block = server_response["data"] as? NSDictionary {
                if let session_data = data_block["session"] as? String {
                    self.login_session = session_data
                    
                    let preferences = UserDefaults.standard
                    preferences.set(session_data, forKey: "session")
                    preferences.set(true, forKey: "touchIdEnrolled")
                    
                    DispatchQueue.main.async(execute: self.loginDone)
                }
            } else {
                
                // Display alert message and enable login button
                DispatchQueue.main.async(execute: self.displayMyAlertMessage)
                DispatchQueue.main.async(execute: self.loginToDo)
            }
            
        })
        
        task.resume()
        
        
    }

    
    func loginDone() {
        self.performSegue(withIdentifier: "ShifterPokedexVC", sender: self)
        
        // Enable login button before segue
        //login_button.isEnabled = true
  
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
        
        let url:URL = URL(string: self.url)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        var paramString = ""
        
        for (key, value) in post_data {
            paramString = paramString + (key as! String) + "=" + (value as! String) + "&"
        }
        
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
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
            
            print("check \(server_response)");
            
            if let response_code = server_response["response_code"] as? Int  {
                if(response_code == 200) {
                    let preferences = UserDefaults.standard
                    preferences.set(true, forKey: "touchIdEnrolled")
                    DispatchQueue.main.async(execute: self.loginDone)
                } else {
                    DispatchQueue.main.async(execute: self.loginToDo)
                }
            }
        })
        
        task.resume()
        
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
