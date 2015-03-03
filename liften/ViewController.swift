//
//  ViewController.swift
//  liften
//
//  Created by Trent Rand on 2/25/15.
//  Copyright (c) 2015 applies, llc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 33.424,
        longitude: -111.934)
    
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var destinationField: UITextField!
    
    //Instantiate a location object.
    var locationManager: CLLocationManager = CLLocationManager()
    
    // Hold parsed Place results
    var placesArray: Array<Place>!
    
    var camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(33.424,
        longitude: -111.934, zoom: 15)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after
        // loading the view, typically from a nib.
        self.navigationController?.navigationBar.hidden = false
        // Setup LocationManager to retrieve currentlocation
        locationManager = CLLocationManager()
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.startUpdatingLocation()
        
        //Setup map
        mapView = GMSMapView.mapWithFrame(CGRectMake(0, 64, 600, 487), camera: camera)
        mapView.mapType = kGMSTypeHybrid
        mapView.delegate = self
        mapView.settings.myLocationButton = false
        self.view = mapView
        
        // Add search bar to navigationbar
        let destinationTextField = UITextField(frame: CGRectMake(78, 11, 170, 25))
        destinationTextField.backgroundColor = UIColor.whiteColor()
        destinationTextField.textColor = UIColor.blackColor()
        destinationTextField.font.fontWithSize(16)
        destinationTextField.placeholder = "Destination Search"
        destinationTextField.borderStyle = UITextBorderStyle.RoundedRect
        destinationTextField.textAlignment = NSTextAlignment.Center
        destinationTextField.autocorrectionType = UITextAutocorrectionType.Yes
        destinationTextField.delegate = self
        self.navigationController?.navigationBar.addSubview(destinationTextField)
        
        // Setup cache
        NSCache.sharedInstance.name = "cache"
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = false
    }

    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
    }
    
    func locationManager(
        manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("didFailWithError: %@", error);
        var errorAlert: UIAlertView = UIAlertView(title: "Error", message: "Failed to get your location", delegate: nil, cancelButtonTitle: nil)
        errorAlert.show()
    }

    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        NSLog("didUpdateToLocation: %@", newLocation);
        currentLocation = newLocation.coordinate
    }
    
    @IBAction func clearButtonPressed(sender: AnyObject) {
        destinationField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        // Search for the entered destination
        
        //  Create location around which to search (hardcoded location of ASU TEMPE here)
        var locationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(33.424,-111.934)
        
        //  Create request searching nearest galleries and museums
        var request: FTGooglePlacesAPINearbySearchRequest = FTGooglePlacesAPINearbySearchRequest(locationCoordinate: locationCoordinate)
        request.rankBy = FTGooglePlacesAPIRequestParamRankBy.Distance
        request.keyword = textField.text
        
        // Before we execute, lets see if this is precached
        if let cachecheck: FTGooglePlacesAPISearchResponse = NSCache.sharedInstance.objectForKey(textField.text) as? FTGooglePlacesAPISearchResponse {
            NSLog("Places search is cached. Restoring...")
            var response: FTGooglePlacesAPISearchResponse = cachecheck
            self.placesArray = parsePlacesToArray(response.results as NSArray)
            // Drop pins.
            dropPins(placesArray! as Array<Place>)
        } else {
            NSLog("Places search not cached. Searching...")
        
        //  Execute Google Places API request using FTGooglePlacesAPIService
        FTGooglePlacesAPIService.executeSearchRequest(request, withCompletionHandler: {
            (response: FTGooglePlacesAPISearchResponse!, error: NSError!) in
            //  If error is not nil, request failed and you should handle the error
            if (error != nil)
            {
                // Handle error here
                NSLog("Request failed. Error: %@", error)
                
                //  There may be a lot of causes for an error (for example networking error).
                //  If the network communication with Google Places API was successfull,
                //  but the API returned some non-ok status code, NSError will have
                //  FTGooglePlacesAPIErrorDomain domain and status code from
                //  FTGooglePlacesAPIResponseStatus enum
                //  You can inspect error's domain and status code for more detailed info
            }
            
            //  Everything went fine, we have response object we can process
            NSLog("Request succeeded. Response: %@", response)
            
            // Save Places result to cache
            NSCache.sharedInstance.setObject(request, forKey: textField.text)
            
            self.placesArray = self.parsePlacesToArray(response.results as NSArray)
            // Drop pins.
            self.dropPins(self.placesArray! as Array<Place>)
        })
        }
        
        
        
        return true
        }
    
    func parsePlacesToArray(results: NSArray) -> Array<Place> {
        // Create an array to store all parsed places
        var placesArray: Array<Place> = []
        
        // For each of the results, parse
        for (var i: Int = 0; i<results.count; i++) {
                // Create a container object (model)
            var place: Place = Place(_name: results[i].name, _address: results[i].addressString, _location: results[i].location)
            
                // Append model to <placesArray>
                placesArray.append(place)
            NSLog("\(placesArray[i].name) \t \(placesArray[i].address) \t \(placesArray[i].lat), \(placesArray[i].long)")
        }
        // Return the parsed places
        return placesArray
    }
    
    func dropPins(pinPlaces: Array<Place>) {
        // Loop through pinPlaces array, drop a pin on each one
        for place: Place in pinPlaces {
            var marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake(place.location.coordinate.latitude, place.location.coordinate.longitude)
            marker.title = place.name
            marker.snippet = place.address
            marker.map = mapView
            NSLog(marker.description)
        }
    }
}

