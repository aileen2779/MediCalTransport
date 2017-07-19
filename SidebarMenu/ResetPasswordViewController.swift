import UIKit
import FirebaseDatabase
import FirebaseAuth

class ResetPasswordViewController: UIViewController {
    
    var pickerData: [String] = [String]()
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // change navigation title color
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func resetPasswordButtonTapped(_ sender: Any) {
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


    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    
    // Dismiss the keyboard when not editing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    
}
