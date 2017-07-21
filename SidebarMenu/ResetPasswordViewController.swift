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
        
        view.backgroundColor = CONST_BGCOLOR
        
        // change navigation title color
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func resetPasswordButtonTapped(_ sender: Any) {
        reesetPassword(phoneNumber: "7022736420", firstName:  "Gamy")
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

    
    
    func reesetPassword(phoneNumber:String, firstName:String) {
        
        let url:URL = URL(string: "https://textbelt.com/text")!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let paramString = "phone=\(phoneNumber)&message=\(firstName)&key=7aeb4e18f8328b578a5f9a2e7ca6fec8980edb53dzQLAbRJjzd2e7IbrOc1bH8vg"
        
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
            if let data_block = server_response["sending"] as? NSDictionary {
                print(data_block)
            } else {
                //
            }
            
        })
        
        task.resume()
        
        
    }
    
    
    
}
