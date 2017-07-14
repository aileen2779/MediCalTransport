import UIKit

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var pickerData: [String] = [String]()
    
    @IBOutlet weak var phcpPickerView: UIPickerView!
    
    @IBOutlet weak var emailAddressTextField: CustomTextField!
    @IBOutlet weak var firstNameTextField: CustomTextField!
    @IBOutlet weak var lastNameTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var passwordConfirmTextField: CustomTextField!
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var createAnAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // change navigation title color
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        // change radius
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
        let userEmailAddress = emailAddressTextField.text
        let userFirstName = firstNameTextField.text
        let userLastName = lastNameTextField.text
        let userPassword = passwordTextField.text
        let userPasswordConfirm = passwordConfirmTextField.text

        // Check for empty fields
        if (userEmailAddress?.isEmpty)! {
            animateMe(textField: self.emailAddressTextField)
            return
        }
        
        if !self.validate(email: userEmailAddress!) {
            animateMe(textField: self.emailAddressTextField)
            return
        }
        
        if (userFirstName?.isEmpty)! {
            animateMe(textField: self.firstNameTextField)
            return
        }
        if (userLastName?.isEmpty)! {
            animateMe(textField: self.lastNameTextField)
            return
        }
        if (userPassword?.isEmpty)! {
            animateMe(textField: self.passwordTextField)
            return
        }
        if (userPasswordConfirm?.isEmpty)! {
            animateMe(textField: self.passwordConfirmTextField)
            return
        }

        if (userPassword != userPasswordConfirm) {
            animateMe(textField: self.passwordTextField)
            animateMe(textField: self.passwordConfirmTextField)
            return
        }
        
        createAnAccountButton.isEnabled = false

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
}
