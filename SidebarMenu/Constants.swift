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


func vibrate(howMany: Int) {
    let x = Int(howMany)
    for _ in 1...x {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        //sleep(1)
    }
}



