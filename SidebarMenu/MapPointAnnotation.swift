import UIKit
import MapKit

class MapPointAnnotation : MKPointAnnotation {
    var venue:Venue?
  
    deinit{
        self.venue = nil
    }
}


struct Position {
    var lat:Double
    var lng:Double
}


class Venue {
    var ident: String
    var name: String
    var lat: Double
    var lng: Double
    var city: String
    var address: String
    var category: String
    
    init(aIdent:String, aName: String, aAddress: String,  aCity: String, aCategory: String, aLat: Double, aLng: Double){
        ident = aIdent
        name = aName
        address = aAddress
        city = aCity
        category = aCategory
        lat = aLat
        lng = aLng
    }
    
}



