//
//  Constants.swift


import Foundation
import AudioToolbox

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


