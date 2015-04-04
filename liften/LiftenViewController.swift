//
//  LiftinViewController.swift
//  liften
//
//  Created by Trent Rand on 3/30/15.
//  Copyright (c) 2015 applies, llc. All rights reserved.
//

import Foundation
import MapKit

class LiftenViewController: UIViewController, MKMapViewDelegate  {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var searchDestination: UISearchBar!
    // Location manager
    var locationManager: CLLocationManager = CLLocationManager()
    var searchResultPlaces: NSArray! = []
    var selectedPlaceAnnotation: MKPointAnnotation!
    var searchQuery: SPGooglePlacesAutocompleteQuery!
    var shouldBeginEditing: Bool! = true

    
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    func searchPlaces(searchValue: String) {
        searchQuery = SPGooglePlacesAutocompleteQuery(apiKey: "AIzaSyDwSEcwaOzrhh24SQNVHCQS4gMgSUqTf4s")
        searchQuery.input = searchDestination.text; // search key word
        searchQuery.location = mapView.userLocation.coordinate  // user's current location
        searchQuery.radius = 100.0;   // search addresses close to user
        searchQuery.language = "en"; // optionally sets laguage as english
        searchQuery.types = SPGooglePlacesAutocompletePlaceType.PlaceTypeAll; // Only return geocoding (address) results.
        
        // Center mapView on current user location
        mapView.setCenterCoordinate(mapView.userLocation.coordinate, animated: true)
        
        // Fetch query results
        searchQuery.fetchPlaces( { (places: [AnyObject]!, error: NSError!) in
            // Drop pins for all search results
            NSLog("Places returned: \(places)")
            self.searchResultPlaces = places as NSArray
        } )
    }
}