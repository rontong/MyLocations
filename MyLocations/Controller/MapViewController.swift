//
//  MapViewController.swift
//  MyLocations
//
//  Created by Ronald Tong on 5/8/18.
//  Copyright © 2018 StokeDesign. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    var locations = [Location]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations()
        
        if !locations.isEmpty {
            showLocations()
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    // Use a Property Observer to listen for changes to the data store and update the MapView when a notification is received
    
    // When the NSManagedObjectContext is given a value the didSet block is performed. Tell the NotificationCenter to add an observer for the NSManagedObjectContextObjectsDidChange notification
    // managedObjectContext sends out this notification whenever the data store changes. Call the closure whenever the notification is received
    
    var managedObjectContext: NSManagedObjectContext! {
        didSet {
            NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext, queue: OperationQueue.main) { (notification) in
                if self.isViewLoaded{
                    self.updateLocations()
                    
                    // TO DO: - Edit code to only update inserted, deleted, and updated annotations
                    
                    if let dictionary = notification.userInfo {
                        print(dictionary["inserted"])
                        print(dictionary["deleted"])
                        print(dictionary["updated"])
                    }
                }
            }
        }
    }
    
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    // Call the region function to calculate a region that fits all Location objects, then set the region on Map View
    
    @IBAction func showLocations() {
     let theRegion = region(for: locations)
        mapView.setRegion(theRegion, animated: true)
    }
    
    // Removes existing annotations, fetches Location objects and adds annotations to the MapView
    
    func updateLocations() {
        mapView.removeAnnotations(locations)
        
        let entity = Location.entity()
        
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = entity
        
        locations = try! managedObjectContext.fetch(fetchRequest)
        mapView.addAnnotations(locations)
    }
    
    // Case 0: no annotations, centre the map on the user's current position
    // Case 1: only one annotation, centre the map on that annotation
    // Default: two or more annotations, find the furthest latitude and longitude by using a for-in-loop, then determine the centre
    
    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion
        
        switch annotations.count {
        case 0: region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
            
        case 1: let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
            
        default:
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            
            for annotation in annotations {
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D(latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2,
                                                longitude: topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
            let extraSpace = 1.1
            
            let span = MKCoordinateSpan(latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace,
                                        longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
           
            region = MKCoordinateRegion(center: center, span: span)
        }
        
        return mapView.regionThatFits(region)
        
        }
    
    // Invoke when disclosure button on a pin callout is tapped
    
    @objc func showLocationDetails(_ sender: UIButton) {
        performSegue(withIdentifier: "EditLocation", sender: sender)
    }
    
    // Prepare for segue when disclosure button on pin callout is tapped
    // Give the LocationDetailsVC the managedObjectContext and locationToEdit (using the button.tag)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            
            controller.managedObjectContext = managedObjectContext
            
            let button = sender as! UIButton
            let location = locations[button.tag]
            controller.locationToEdit = location
        }
    }
}

    // MARK: - Map View Delegate Methods

extension MapViewController: MKMapViewDelegate {
   
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      
        // Guard statement: if the result is nil/false then perform the code in the else block
        // If annotation is a Location object then continue. Otherwise return nil and do not make an annotation for the object
        
        guard annotation is Location else {
            return nil
        }
        
        // Ask Map View to reuse an annotation view object. If it cannot recycle an annotation then create a new one
        
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = false
            pinView.pinTintColor = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1)
            pinView.tintColor = UIColor(white: 0.0, alpha: 0.5)
            
            // Create a UIButton that looks like a detail disclosure and link the touchUpInside action with a showLocationDetails method
            
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.addTarget(self, action: #selector(showLocationDetails), for: .touchUpInside)
            
            pinView.rightCalloutAccessoryView = rightButton
            
            annotationView = pinView
        }
        
        // If an annotationView exists (annotation view object has been reused or created) then set the annotation to the location object
        
        if let annotationView = annotationView {
            annotationView.annotation = annotation
            
            // Obtain a reference to the detail disclosure button and set its tag to the index of the Location object in the array
            
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            if let index = locations.index(of: annotation as! Location) {
                button.tag = index
            }
        }
        return annotationView
    }
}

    // MARK: - Navigation Bar Delegate Methods

    // Extend the navigation bar to be underneath the status bar area

extension MapViewController: UINavigationBarDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
