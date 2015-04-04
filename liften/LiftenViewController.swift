//
//  LiftinViewController.swift
//  liften
//
//  Created by Trent Rand on 3/30/15.
//  Copyright (c) 2015 applies, llc. All rights reserved.
//

import Foundation
import MapKit

class LiftenViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var searchDestination: UISearchBar!
    // Location manager
    var locationManager: CLLocationManager = CLLocationManager()
    var searchResultPlaces: NSArray! = []
    var selectedPlaceAnnotation: MKPointAnnotation!
    var searchQuery: SPGooglePlacesAutocompleteQuery!
    var shouldBeginEditing: Bool! = true
    var userChannel: PNChannel!

    
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Setup location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 5.0
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.setCenterCoordinate(self.mapView.userLocation.coordinate, animated: true)
       
        self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        
        
        //Define a channel
        userChannel = PNChannel.channelWithName("users", shouldObservePresence: true) as PNChannel
        PubNub.subscribeOn([userChannel])

        PNObservationCenter.defaultCenter().addClientConnectionStateObserver(self, withCallbackBlock: {
            (origin: String!, connected: Bool!, connectionError: PNError!) in
            if ((connected) != nil) {
                NSLog("OBSERVER: Successful Connection!")
                // Subscribe if client connects successfully
                PubNub.subscribeOn([self.userChannel])
            } else if ((connected == nil) || !connectionError.isEqual(nil))  {
                NSLog("OBSERVER: Error \(connectionError.localizedDescription), Connection Failed!")
            }
        })
        
        // Added Observer to look for message received events
        PNObservationCenter.defaultCenter().addMessageReceiveObserver(self, withBlock: {
            (message: PNMessage!) in
            self.markMessageOnMap(message)
        })
        

    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        //Publish location on the channel
        PubNub.sendMessage([PFUser.currentUser().username, locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude], toChannel: userChannel)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        mapView.setCenterCoordinate(self.mapView.userLocation.coordinate, animated: true)
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
    
    func markMessageOnMap(message: PNMessage) {
        NSLog("Should mark map here \(message.message)")
        // Create your coordinate
        var pinCoords: CLLocationCoordinate2D = CLLocationCoordinate2DMake(message.message.objectAtIndex(1) as CLLocationDegrees, message.message.objectAtIndex(2) as CLLocationDegrees)
        //Create your annotation
        var point: MKPointAnnotation = MKPointAnnotation()
        // Set your annotation to point at your coordinate
        point.coordinate = pinCoords
        //Drop pin on map
        self.mapView.addAnnotation(point)
        
    }
    
}