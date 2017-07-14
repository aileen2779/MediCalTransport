import Foundation

class Patient {
    private var _phoneNumber: String!
    private var _firstName: String!
    private var _lastName: String!
    private var _pcp: String!
    private var _pin: String!
    private var _dateAdded: String!
    
    var phoneNumber: String {
        if _phoneNumber == nil {
            _phoneNumber = ""
        }
        return _phoneNumber
    }
    var firstName: String {
        if _firstName == nil {
            _firstName = ""
        }
        return _firstName
    }

    var lastName: String {
        if _lastName == nil {
            _lastName = ""
        }
        return _lastName
    }

    var pcp: String {
        if _pcp == nil {
            _pcp = ""
        }
        return _pcp
    }

    var dateAdded: String {
        if _dateAdded == nil {
            _dateAdded = ""
        }
        
        return _dateAdded
    }
    
    init(phoneNumber: String,
         firstName: String,
         lastName: String,
         pcp: String,
         dateAdded: String
        ) {
        
        self._phoneNumber = phoneNumber
        self._firstName = firstName
        self._lastName = lastName
        self._pcp = pcp
        self._dateAdded = dateAdded
    }
    
}

