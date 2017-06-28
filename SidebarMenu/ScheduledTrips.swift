//
//  Copyright (c) 2015 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

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
        guard let uid  = dict["uid"]  else { return nil }
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
