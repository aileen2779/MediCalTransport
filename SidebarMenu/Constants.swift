//
//  Constants.swift


import Foundation
import AudioToolbox
import FirebaseDatabase



let CONST_BGCOLOR:UIColor = UIColor(red:0.49, green:0.73, blue:0.71, alpha:1.0)
let CONST_BGCOLOR_DRIVER:UIColor = UIColor(red:1.00, green:0.60, blue:0.00, alpha:1.0)
var CONST_DOMAIN:String = "@zundo.com"
let CONST_IP_URL:String = "https://api.ipify.org?format=json"
let CONST_SMS_API:String = "7aeb4e18f8328b578a5f9a2e7ca6fec8980edb53dzQLAbRJjzd2e7IbrOc1bH8vg"
let CONST_SMS_URL:String = "https://textbelt.com/text"
let CONST_DUMMY_ID:String = "0000000000"
let CONST_GUEST_USER:String = "guest@zundo.com"
let CONST_GUEST_PW:String = "Welcome01"

let CONST_PASSENGER:String = "passenger"
let CONST_DRIVER:String = "driver"

func animateMe(textField: UITextField) {
    let _thisTextField = textField
    UIView.animate(withDuration: 0.1, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {_thisTextField.center.x += 10 }, completion: nil)
    UIView.animate(withDuration: 0.1, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {_thisTextField.center.x -= 20 }, completion: nil)
    UIView.animate(withDuration: 0.1, delay: 0.2, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {_thisTextField.center.x += 10 }, completion: nil)
}

func dropShadow(thisObject: Any) {
    (thisObject as AnyObject).layer.borderColor = UIColor.clear.cgColor
    (thisObject as AnyObject).layer.masksToBounds = false
    (thisObject as AnyObject).layer.shadowColor = UIColor.black.cgColor
    (thisObject as AnyObject).layer.shadowOffset = CGSize.zero
    (thisObject as AnyObject).layer.shadowOpacity = 1
    (thisObject as AnyObject).layer.shadowRadius = 5.0
}

func vibrate(howMany: Int) {
    let x = Int(howMany)
    for _ in 1...x {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        //sleep(1)
    }
}

func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}

func firebaseLog(userID: String, logToSave: Any) {
    
    let _userID:String = userID
            
    let ref = Database.database().reference()
    
    let myDate = Date()
    let myDateFormatter = DateFormatter()
    myDateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
    
    // year
    myDateFormatter.dateFormat = "yyyy"
    let yearString = myDateFormatter.string(from: myDate)

    // month
    myDateFormatter.dateFormat = "MM-MMMM"
    let monthString = myDateFormatter.string(from: myDate)
    
    //day
    myDateFormatter.dateFormat = "dd-EEEE"
    let dayString = myDateFormatter.string(from: myDate)
    
    //timestamp in microseconds
    myDateFormatter.dateFormat = "HH:mm:ss:SSS"
    let hourString = myDateFormatter.string(from: myDate)
    
    let logToSaveDetail = ["/logs/\(yearString)/\(monthString)/\(dayString)/\(_userID)/\(hourString)": logToSave]
    
    ref.updateChildValues(logToSaveDetail)
}



