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
    //myDateFormatter.dateFormat = "MMddyyyy h:mm:ss a"
    myDateFormatter.dateFormat = "yyyy"
    let yearString = myDateFormatter.string(from: myDate)
    print(yearString)
    
    myDateFormatter.dateFormat = "MM"
    let monthString = myDateFormatter.string(from: myDate)
    print(monthString)
    
    myDateFormatter.dateFormat = "dd"
    let dayString = myDateFormatter.string(from: myDate)
    print(dayString)
    
    myDateFormatter.dateFormat = "HH:mm:ss:SSS"
    let hourString = myDateFormatter.string(from: myDate)
    print(hourString)
    
    let logToSaveDetail = ["/logs/\(yearString)/\(monthString)/\(dayString)/\(_userID)/\(hourString)": logToSave]
    
    ref.updateChildValues(logToSaveDetail)
}

