//
//  AppDelegate.swift
//  SidebarMenu


import UIKit
import Firebase
import FirebaseInstanceID
import GooglePlaces


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    var googleAPIKey = "AIzaSyDg2tlPcoqxx2Q2rfjhsAKS-9j0n3JA_a4"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Configure firebase
        FirebaseApp.configure()
        
        // Configure autocomplete
        GMSPlacesClient.provideAPIKey(googleAPIKey)
        
        // Override point for customization after application launch.
        // Sets background to a blank/empty image
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // Sets shadow (line below the bar) to a blank image
        UINavigationBar.appearance().shadowImage = UIImage()
        // Sets the translucent background color
        UINavigationBar.appearance().backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        UINavigationBar.appearance().isTranslucent = true
        
        return true
    }
    

}
