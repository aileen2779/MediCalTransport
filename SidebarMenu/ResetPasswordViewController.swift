import UIKit

class ResetPasswordViewController: UIViewController {
    
    @IBAction func goBackButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var pickerData: [String] = [String]()
    
    @IBOutlet weak var phcpPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
