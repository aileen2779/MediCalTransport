import UIKit

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBAction func goBackButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var pickerData: [String] = [String]()
    
    @IBOutlet weak var phcpPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.phcpPickerView.delegate = self
        self.phcpPickerView.dataSource = self
        
        pickerData = ["Dr. Ben Calderon",
                      "Dr. Aileen Ramos",
                      "Dr. Butch Edano",
                      "Dr. Topher",
                      "Dr. Sammy",
                      "Dr. Joyce"]
       

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
}
