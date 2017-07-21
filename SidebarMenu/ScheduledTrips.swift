import UIKit
import Firebase

class ScheduledTrips: NSObject {
    var uid: String
    var patientid: String
    var fromlocation: String
    var tolocation: String
    var pickupdatetime: String
    var currentlongitude: String
    var currentlatitude: String
    
    init(uid: String, patientid: String, fromlocation: String, tolocation: String, pickupdatetime: String, currentlongitude: String, currentlatitude: String) {
        self.uid = uid
        self.patientid = patientid
        self.fromlocation = fromlocation
        self.tolocation = tolocation
        self.pickupdatetime = pickupdatetime
        self.currentlongitude = currentlongitude
        self.currentlatitude = currentlatitude
        
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: String] else { return nil }
        guard let uid  = dict["uID"]  else { return nil }
        guard let patientid = dict["patientid"] else { return nil }
        guard let fromlocation = dict["from"] else { return nil }
        guard let tolocation = dict["to"] else { return nil }
        guard let pickupdatetime = dict["when"] else { return nil }
        guard let currentlongitude = dict["longitude"] else { return nil }
        guard let currentlatitude = dict["latitude"] else { return nil }
        
        self.uid = uid
        self.patientid = patientid
        self.fromlocation = fromlocation
        self.tolocation = tolocation
        self.pickupdatetime = pickupdatetime
        self.currentlatitude = currentlatitude
        self.currentlongitude = currentlongitude
    }
    
    convenience override init() {
        self.init(uid: "", patientid: "", fromlocation: "", tolocation: "", pickupdatetime: "", currentlongitude: "", currentlatitude: "")
    }
}
