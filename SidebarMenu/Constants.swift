//
//  Constants.swift


import Foundation

//  Make a variable equal to a random number....
let randomNum:UInt32 = arc4random_uniform(1000) // range is 0 to 99

// convert the UInt32 to some other  types
let randomTime:TimeInterval = TimeInterval(randomNum)
let someInt:Int = Int(randomNum)
let someString:String = String(randomNum) //string works too
let URLToken = ("http://www.702shifters.com/json_service.php?token=\(someString)")     // assign a new id everytime so the URL is forced to refresh

let URL_BASE = URL(string: URLToken)
//let URL_POKEMON = "/api/v1/pokemon/"

let URL_AUTH  = "http://www.702shifters.com/ios_auth.php"
let URL_WAIVER  = "http://www.702shifters.com/waiver"

typealias DownloadComplete = () -> ()
