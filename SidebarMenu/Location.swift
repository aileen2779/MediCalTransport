import Foundation

class LocationClass {
    private var _key: String!
    private var _patientID: String!
    private var _fromAddress: String!
    private var _fromLongitude: Double!
    private var _fromLatitude: Double!
    private var _toAddress: String!
    private var _toLongitude: Double!
    private var _toLatitude: Double!
    private var _pickUpDate: String!
    private var _dateAdded: String!

    
    var key: String {
        if _key == nil {
            _key = ""
        }
        return _key
    }
    var patientID: String {
        if _patientID == nil {
            _patientID = ""
        }
        return _patientID
    }
    var fromAddress: String {
        if _fromAddress == nil {
            _fromAddress = ""
        }
        return _fromAddress
    }
    
    var fromLongitude: Double {
        if _fromLongitude == nil {
            _fromLongitude = 0.0
        }
        return _fromLongitude
    }
    
    var fromLatitude: Double {
        if _fromLatitude == nil {
            _fromLatitude = 0.0
        }
        return _fromLatitude
    }
    
    var toAddress: String {
        if _toAddress == nil {
            _toAddress = ""
        }
        return _toAddress
    }

    var toLongitude: Double {
        if _toLongitude == nil {
            _toLongitude = 0.0
        }
        return _toLongitude
    }
    
    var toLatitude: Double {
        if _toLatitude == nil {
            _toLatitude = 0.0
        }
        return _toLatitude
    }


    var pickUpDate: String {
        if _pickUpDate == nil {
            _pickUpDate = ""
        }
        
        return _pickUpDate
    }
    
    
    var dateAdded: String {
        if _dateAdded == nil {
            _dateAdded = ""
        }
        
        return _dateAdded
    }
    
    init(key: String,
         patientID: String,
         fromAddress: String,
         fromLongitude: Double,
         fromLatitude: Double,
         toAddress: String,
         toLongitude: Double,
         toLatitude: Double,
         pickUpDate: String,
         dateAdded: String
         ) {

        self._key = key
        self._patientID = patientID
        self._fromAddress = fromAddress
        self._fromLatitude = fromLatitude
        self._fromLongitude = fromLongitude
        self._toAddress = toAddress
        self._toLongitude = toLongitude
        self._toLatitude = toLatitude
        self._pickUpDate = pickUpDate
        self._dateAdded = dateAdded
    }
    
}

