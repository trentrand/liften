//
//  LiftinViewController.swift
//  liften
//
//  Created by Trent Rand on 3/30/15.
//  Copyright (c) 2015 applies, llc. All rights reserved.
//

import Foundation
import MapKit

class LiftenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, MKMapViewDelegate  {
    
    @IBOutlet var searchDestination: UISearchBar!
    @IBOutlet var mapView: MKMapView!
    
    // Location manager
    var locationManager: CLLocationManager = CLLocationManager()
    var searchResultPlaces: NSArray! = []
    var selectedPlaceAnnotation: MKPointAnnotation!
    var searchQuery: SPGooglePlacesAutocompleteQuery!
    var shouldBeginEditing: Bool! = true

    
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        searchDestination.clipsToBounds = true
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // Hide keyboard
        searchBar.endEditing(true)
        searchPlaces(searchBar.text)
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
    
    // UITableViewDataSource Delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultPlaces.count
    }
    
    func placeAtIndexPath(indexPath: NSIndexPath) -> SPGooglePlacesAutocompletePlace {
        return searchResultPlaces[indexPath.row] as SPGooglePlacesAutocompletePlace
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier: String = "SPGooglePlacesAutocompleteCell"
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        if (cell.isEqual(nil)) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        cell.textLabel?.font = UIFont(name: "GillSans", size: 16.0)
        cell.textLabel?.text = self.placeAtIndexPath(indexPath).name
        return cell
    }
    
    // UITableViewDelegate delegate
    func recenterMapToPlacemark(placemark: CLPlacemark) {
        var span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        var region: MKCoordinateRegion = MKCoordinateRegion(center: placemark.location.coordinate, span: span)
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func addPlacemarkAnnotationToMap(placemark: CLPlacemark, address: String) {
        self.mapView.removeAnnotation(selectedPlaceAnnotation)
        
        selectedPlaceAnnotation = MKPointAnnotation()
        selectedPlaceAnnotation.coordinate = placemark.location.coordinate
        selectedPlaceAnnotation.title = address
        self.mapView.addAnnotation(selectedPlaceAnnotation)
    }
    
    func dismissSearchControllerWhileStayingActive() {
        // Animate out the table view
        var animationDuration: NSTimeInterval = 0.3
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(animationDuration)
        self.searchDisplayController?.searchResultsTableView.alpha = 0.0
        UIView.commitAnimations()
        
        self.searchDisplayController?.searchBar.setShowsCancelButton(false, animated: true)
        self.searchDisplayController?.searchBar.resignFirstResponder()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var place: SPGooglePlacesAutocompletePlace = self.placeAtIndexPath(indexPath)
        place.resolveToPlacemark({ (placemark: CLPlacemark!, addressString: String!, error: NSError!) in
            if ((error) != nil) {
                var alert: UIAlertView = UIAlertView(title: "Could not map selected places", message: error.localizedDescription, delegate: nil, cancelButtonTitle: nil)
                alert.show()
                
            } else if (placemark != nil) {
                self.addPlacemarkAnnotationToMap(placemark, address: addressString)
                self.recenterMapToPlacemark(placemark)
                self.dismissSearchControllerWhileStayingActive()
                self.searchDisplayController?.searchResultsTableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
        })
    }
    
    
    // UISearchDisplayDelegate delegate
    
    func handleSearchForSearchString(searchString: String) {
        searchQuery.location = self.mapView.userLocation.coordinate
        searchQuery.input = searchString
        searchQuery.fetchPlaces({ (places: [AnyObject]!, error: NSError!) in
            if (error != nil) {
                var alert: UIAlertView = UIAlertView(title: "Could not fetch places", message: error.localizedDescription, delegate: nil, cancelButtonTitle: nil)
                alert.show()
            } else {
                self.searchResultPlaces = places
                self.searchDisplayController?.searchResultsTableView.reloadData()
            }
        })
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.handleSearchForSearchString(searchString)
        
        // Return true to cause the search result table view to be reloaded
        return true
    }
    
    // UISearchBar Delegate
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (!searchBar.isFirstResponder()) {
            // User tapped the clear button
            shouldBeginEditing = false
            self.searchDisplayController?.setActive(false, animated: true)
            self.mapView.removeAnnotation(selectedPlaceAnnotation)
        }
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        if ((shouldBeginEditing) != nil) {
            // Animate in the table view
            var animationDuration: NSTimeInterval = 0.3
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(animationDuration)
            self.searchDisplayController?.searchResultsTableView.alpha = 0.75
            UIView.commitAnimations()
            
            self.searchDisplayController?.searchBar.setShowsCancelButton(true, animated: true)
        }
        var boolToReturn: Bool = shouldBeginEditing!
        shouldBeginEditing = true
        return boolToReturn
    }
    
    // MKMapView Delegate
    
    func mapView(mapViewIn: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (mapViewIn != self.mapView || annotation.isKindOfClass(MKUserLocation)) {
            return nil
        }
        let annotationIdentifier: String = "SPGooglePlacesAutocompleteAnnotation"
        var annotationView: MKPinAnnotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier(annotationIdentifier) as MKPinAnnotationView
        
        if (annotationView.isEqual(nil)) {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        annotationView.animatesDrop = true
        annotationView.canShowCallout = true
        
        var detailButton: UIButton = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
        detailButton.addTarget(self, action: "annotationDetailButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        annotationView.rightCalloutAccessoryView = detailButton
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        // Whever we've dropped a pin on the map, immediately select it to present its callout bubble
        self.mapView.selectAnnotation(selectedPlaceAnnotation, animated: true)
    }
    
    func annotationDetailButtonPressed(sender: AnyObject) {
        // Detail view controller application logic here
    }
}