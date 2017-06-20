//
//  Pokemon.swift
//  pokedex3


import Foundation
//import Alamofire

class ShifterClass {
    
    private var _name: String!
    private var _userName: String!
    private var _userId: Int!
    private var _description: String!
    private var _address1: String!
    private var _city: String!
    private var _state: String!
    private var _zip: String!
    private var _country: String!
    private var _phone1: String!
    private var _emergencyName: String!
    private var _emergencyNum: String!
    private var _email: String!
    private var _membership: String!
    
    private var _membership_paid: String!
    private var _membership_start: String!
    private var _membership_end: String!
    private var _membership_status: String!
    private var _payment_gateway: String!
    private var _waiver_form: String!

    
    var userName: String {
        if _userName == nil {
            _userName = ""
        }
        return _userName
    }

    var waiver_form: String {
        if _waiver_form == nil {
            _waiver_form = ""
        }
        return _waiver_form
    }
    
    var description: String {
        if _description == nil {
            _description = ""
        }
        return _description
    }
    
    var address1: String {
        if _address1 == nil {
            _address1 = ""
        }
        return _address1
    }
    
    var city: String {
        if _city == nil {
            _city = ""
        }
        return _city
    }
    
    var state: String {
        if _state == nil {
            _state = ""
        }
        return _state
    }
    
    var zip: String {
        if _zip == nil {
            _zip = ""
        }
        return _zip
    }
    
    var country: String {
        if _country == nil {
            _country = ""
        }
        return _country
    }
    
    var emergencyName: String {
        if _emergencyName == nil {
            _emergencyName = ""
        }
        return _emergencyName
    }
    
    var emergencyNum: String {
        if _emergencyNum == nil {
            _emergencyNum = ""
        }
        return _emergencyNum
    }
    
    var phone1: String {
        if _phone1 == nil {
            _phone1 = ""
        }
        return _phone1
    }
    
    var name: String {
        return _name
    }
    
    var userId: Int {
        return _userId
    }
    
    
    var email: String {
        if _email == nil {
            _email = ""
        }
        return _email
    }
    
    var membership: String {
        if _membership == nil {
            _membership = ""
        }
        return _membership
    }
    
    

    var membership_paid: String {
        if _membership_paid == nil {
            _membership_paid = ""
        }
        return _membership_paid
    }
    
    var membership_start: String {
        if _membership_start == nil {
            _membership_start = ""
        }
        return _membership_start
    }
    
    var membership_end: String {
        if _membership_end == nil {
            _membership_end = ""
        }
        return _membership_end
    }
    
    var membership_status: String {
        if _membership_status == nil {
            _membership_status = ""
        }
        return _membership_status
    }
    
    var payment_gateway: String {
        if _payment_gateway == nil {
            _payment_gateway = ""
        }
        return _payment_gateway
    }
    
    
    
    init(name: String,
         userId: Int,
         userName: String,
         address1: String,
         city: String,
         state: String,
         zip: String,
         country: String,
         emergencyName: String,
         emergencyNum: String,
         phone1: String,
         email: String,
         membership: String,
         membership_paid: String,
         membership_start: String,
         membership_end: String,
         membership_status: String,
         payment_gateway: String,
         waiver_form: String
        ) {
        
        self._name = name
        self._userId = userId
        self._userName = userName
        self._address1 = address1
        self._city = city
        self._state = state
        self._zip = zip
        self._country = country
        self._emergencyName = emergencyName
        self._emergencyNum = emergencyNum
        self._phone1 = phone1
        self._email = email
        self._membership = membership
        self._membership_paid = membership_paid
        self._membership_start = membership_start
        self._membership_end = membership_end
        self._membership_status = membership_status
        self._payment_gateway = payment_gateway
        self._waiver_form = waiver_form
    }
    
}

