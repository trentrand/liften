//
//  Place.swift
//  liften
//
//  Created by Trent Rand on 2/27/15.
//  Copyright (c) 2015 applies, llc. All rights reserved.
//

import Foundation

class Place: NSObject {
    var name: String!
    var lat: Float!
    var long: Float!
    var address: String!
    var location: CLLocation!
    
    init(_name: String, _address: String, _location: CLLocation) {
        super.init()
        
        // Set model variables to constructor fields
        self.name = _name
        self.address = _address
        self.location = _location
        lat = _location.coordinate.latitude.description.floatValue
        long = _location.coordinate.longitude.description.floatValue
    }
}

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}