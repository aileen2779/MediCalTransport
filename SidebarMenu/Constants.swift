//
//  Constants.swift


import Foundation
import AudioToolbox
import FirebaseDatabase



var CONST_BG_COLOR:UIColor = UIColor(red:0.49, green:0.73, blue:0.71, alpha:1.0)


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
    myDateFormatter.dateFormat = "MM"
    let monthString = myDateFormatter.string(from: myDate)
    
    //day
    myDateFormatter.dateFormat = "dd"
    let dayString = myDateFormatter.string(from: myDate)
    
    //timestamp in microseconds
    myDateFormatter.dateFormat = "HH:mm:ss:SSS"
    let hourString = myDateFormatter.string(from: myDate)
    
    let logToSaveDetail = ["/logs/\(yearString)/\(monthString)/\(dayString)/\(_userID)/\(hourString)": logToSave]
    
    ref.updateChildValues(logToSaveDetail)
}

/*
func getIPAddress() -> String {
    var address: String = "error"
    
    var interfaces: ifaddrs? = nil
    
    var temp_addr: ifaddrs? = nil
    var success: Int = 0
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(interfaces)
    if success == 0 {
        // Loop through linked list of interfaces
        temp_addr = interfaces
        while temp_addr != nil {
            if temp_addr?.ifa_addr?.sa_family == AF_INET {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if (String(utf8String: temp_addr?.ifa_name) == "en0") {
                    // Get NSString from C String
                    address = String(utf8String: inet_ntoa((temp_addr?.ifa_addr as? sockaddr_in)?.sin_addr))
                }
            }
            temp_addr = temp_addr?.ifa_next
        }
    }
    // Free memory
    freeifaddrs(interfaces)
    return address
}
 */
