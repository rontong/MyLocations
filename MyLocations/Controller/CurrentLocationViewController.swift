//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Ronald Tong on 1/7/18.
//  Copyright © 2018 StokeDesign. All rights reserved.
//
// Continue p178, error unwrapping optional

import UIKit
import CoreLocation
import CoreData
import QuartzCore
import AudioToolbox

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate, CAAnimationDelegate {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    @IBOutlet weak var latitudeTextLabel: UILabel!
    @IBOutlet weak var longitudeTextLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    let locationManager = CLLocationManager()
    
    var location: CLLocation?
    var lastLocationError: Error?
    var updatingLocation = false
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var lastGeocodingError: Error?
    var performingReverseGeocoding = false
    
    var timer: Timer?
    
    var managedObjectContext: NSManagedObjectContext!
    
    var logoVisible = false
    
    var soundID: SystemSoundID = 0
    
    // Create a custom UI Button using Logo.png image that calls getLocation() when tapped
    // () Needed after {} to initialise the stored property within a closure
    lazy var logoButton: UIButton = {
        
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "Logo"), for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(getLocation), for: .touchUpInside)
        
        button.center.x = self.view.bounds.midX
        button.center.y = 220
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetButton()
        loadSoundEffect("Sound.caf")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Passes the managedObjectContext reference to LocationDetailsVC to talk to CoreData
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
        }
    }
    
    // Checks current authorization status. If notDetermined then app will request "When In Use" Authorization. Alternatively use "Always" authorization.
    // Alert is shown if authorization is denied or restricted; location manager is not started and labels not updated.
    // If AuthStatus is not notDetermined, denied, or restricted then the rest of the method is implemented and actions called
    // If updatingLocation is true then pressing the button will stop the Location Manager. If it is false then pressing the button will start the Location Manager.
    
    @IBAction func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        if logoVisible {
            print("** Get Location Pressed. Logo is Visible, Hide the Logo View")
            hideLogoView()
        }
        
        if updatingLocation {
            stopLocationManager()
            
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
        configureGetButton()
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // Location instance variable is optional, thus use if let. If the location variable is not nil, then convert latitude and longitude into Strings and place them into labels
    // Format string used to control the number of decimal points. Placeholders always start with %. %d for integer, %f for decimals, %@ for arbitrary objects. ".8" means there should always be 8 digits behind the decimal point
    // If the location manager gave an error, label will show an error message. kCLErrorDomain means a Core Location error, otherwise all other errors display a generic error message.
    // If the geocoder has a placemark, then update the address Label depending on the status, error, or placemark returned
    
    func updateLabels(){
        if let location = location {
            latitudeLabel.text = String(format:"%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
            
            latitudeTextLabel.isHidden = false
            longitudeTextLabel.isHidden = false
            
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address"
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
            
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            messageLabel.text = "Tap 'Get My Location' to Start"
        
        let statusMessage: String
        if let error = lastLocationError as? NSError {
            if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                statusMessage = "Location Services Disabled. Please enable Location Services in Settings"
            } else {
                statusMessage = "Error Getting Location"
            }
        } else if !CLLocationManager.locationServicesEnabled() {
            statusMessage = "Location Services Disabled"
        } else if updatingLocation {
            statusMessage = "Searching..."
        } else {
            statusMessage = ""
            print("No Coordinates or Error Messages to Display")
            showLogoView()
        }
        
        messageLabel.text = statusMessage
        latitudeTextLabel.isHidden = true
        longitudeTextLabel.isHidden = true
        }
    }
    // MARK: - Logo View
    
    // Hide container view (labels) and place logoButton object on screen
    func showLogoView() {
        print("*** SHOW LOGO VIEW")
        if !logoVisible {
            logoVisible = true
            containerView.isHidden = true
            view.addSubview(logoButton)
        }
    }
    
    func hideLogoView() {
        print("*** HIDE LOGO VIEW")
        
        if !logoVisible { return }
        
        logoVisible = false
        containerView.isHidden = false
        containerView.center.x = view.bounds.size.width * 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        
        let centerX = view.bounds.midX
        
        let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.isRemovedOnCompletion = false
        panelMover.fillMode = kCAFillModeForwards
        panelMover.duration = 0.6
        panelMover.fromValue = NSValue(cgPoint: containerView.center)
        panelMover.toValue = NSValue(cgPoint: CGPoint(x: centerX, y: containerView.center.y))
        panelMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        panelMover.delegate = self
        containerView.layer.add(panelMover, forKey: "panelMover")
        
        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.isRemovedOnCompletion = false
        logoMover.fillMode = kCAFillModeForwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(cgPoint: logoButton.center)
        logoMover.toValue = NSValue(cgPoint: CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction( name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.add(logoMover, forKey: "logoMover")
        
        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode = kCAFillModeForwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * M_PI
        logoRotator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.add(logoRotator, forKey: "logoRotator")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        containerView.layer.removeAllAnimations()
        containerView.center.x = view.bounds.size.width / 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        logoButton.layer.removeAllAnimations()
        logoButton.removeFromSuperview()
    }
    
    
    // Set up for location manager. Telling it who is the delegate and setting accuracy, then calling the action.
    // Sets up a timer object that sends a didTimeOut message to self after 60 seconds
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)        }
    }
    
    // If updatingLocation is true then perform the {} to stop updating location. Otherwise there is no need to stop it.
    // When an accurate location is found, then location manager is stopped. If this is the case then cancel the timer before it fires
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    // If updatingLocation variable is true then set the title to "Stop" and create an activity indicator, otherwise set to "Get My Location"
    
    func configureGetButton(){
        let spinnerTag = 1000
       
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
            
            if view.viewWithTag(spinnerTag) == nil {
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
                spinner.center = messageLabel.center
                spinner.center.y += spinner.bounds.size.height/2 + 15
                spinner.startAnimating()
                spinner.tag = spinnerTag
                containerView.addSubview(spinner)
            }
        } else {
            getButton.setTitle("Get My Location", for: .normal)
            
            if let spinner = view.viewWithTag(spinnerTag) {
                spinner.removeFromSuperview()
            }
        }
    }
    
    // Called after one minute regardless of whether a location is obtained. Unless the stopLocationManager cancels the timer first.
    // Stops location manager, creates a custom error code and updates the screen. Ensure this is not kCLErrorDomain as this ecustom rror object does not come from Core Location
    
    @objc func didTimeOut() {
        print("*** Time out")
        
        if location == nil {
            stopLocationManager()
            
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            
            updateLabels()
            configureGetButton()
            
        }
    }
    
    
    //MARK: - CLLocationManagerDelegate Methods

// DID FAIL WITH ERROR DELEGATE FUNCTION
    // CL Location Manager Delegate Method, deals with Errors:
    // Look at the code property to find what error you are dealing with. If it is simply locationUnknown then keep trying to find location until there is a more serious error. Return without executing the rest of the function.
    // If there is a more serious error then perform the rest of the function; store that error object into lastLocationError, stop the location manager, and update labels.
    // rawValue converts an enum back to an integer value
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        
        lastLocationError = error
        
        stopLocationManager()
        updateLabels()
        configureGetButton()
    }
    
// DID UPDATE LOCATIONS DELEGATE FUNCTION
    // If the time since the location was given is more than 5 seconds, it is too long and considered a cached result. Ignore this and keep updating locations
    // If the new location's horizontal accuracy is negative then this is invalid, ignore this and keep updating locations
    // Calculate the distance between the new and previous reading; use this distance to measure if location updates are improving. DBL_MAX is the maximum floating-point number (ie. first reading will always be giant).
    
    // If the location is nil (first location update) or the new location is more accurate than the previous location then set the lastLocationError to nil to clear out old error states and update labels. Keeps updating locations in case there are more accurate locations.
    // location!horizontalAccuracy was force unwrapped safely due to short circuiting. || tests whether either of the conditions is true; if the first is true it will ignore the second. Ie. Xcode will only look at location! when location is guaranteed to be non-nil.
    // If the new location accuracy is better than the desired accuracy, stop the location manager
    
    // Setting performingReverseGeocoding to false forces the app to reverse Geocode the final location (as if !performingReverseGeocoding will call a method next). If distance is = 0 then the location is the same as the previous reading and there is no need to reverse geocode it, therefore >0 means it is a new location and needs to be geocoded.
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
       
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude) //DBL_MAX
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            
            lastLocationError = nil
            location = newLocation
            updateLabels()
        }
        
        if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
            print("*** We're done! Location accuracy is good.")
            stopLocationManager()
            configureGetButton()
            
            if distance > 0 {
                performingReverseGeocoding = false
            }
        }
        
   // GEOCODER
        // First check to see if the geocoder is busy; the app should only perform one geocode request at a time
        // If geocoder is not performing reverse geocoding then start the geocoder and set its status to true
        // completionHandler uses a closure; the code inside {} is executed only after geocoding is completed. self must be used inside closures as variables are captured.
        // Parameters for the closure: placemarks contains an array of CLPlacemark objects with address information, error contains error message if something went wrong
        // Once the geocoders finds a result for the location object given, it invokes the closure and executes the statements contained
        
        // Store the error object as lastGeocodingError
        // !p.isEmpty means only enter this if statement if the array of placemark objects is not empty
        // If there is no error and the unwrapped placemarks array is not empty then perform then set placemark to the last object in the placemarks array
        // If there is an error then set placemark to nil as you do not want to show an old address or no address
        // last! refers to the last item in an array, optional as there is no item if the array is empty. Can also be written placemarks[placemarks.count - 1]
        
        // If the distance between readings is not significantly different (<1) AND it has been more than 10 seconds since receiving that reading, then stop updating locations
        
        if !performingReverseGeocoding {
            print("*** Going to geocode")
            
            performingReverseGeocoding = true
            
            geocoder.reverseGeocodeLocation(newLocation, completionHandler: {placemarks, error in
                print("*** Found placemarks: \(placemarks), error: \(error)")
                
                self.lastGeocodingError = error
                if error == nil, let p = placemarks, !p.isEmpty {
                    
                    // If placemark is nil then it is the first time reverse geocoding an address. Play the Sound. 
                    if self.placemark == nil {
                        print("FIRST TIME!")
                        self.playSoundEffect()
                    }
                    
                    self.placemark = p.last!
                } else {
                    self.placemark = nil
                }
                self.performingReverseGeocoding = false
                self.updateLabels()
            })
            
        } else if distance < 1 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10 {
                print("*** Force done!")
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
    }
    
    
    // If the placemark has a subThoroughfare (house number) then add it to the string line1. Perform the same logic for thoroughfare (street name), locality (city), administrative area (state), and postal code
    // \n adds a line break into the string
    
    func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        
        line1.add(text: placemark.subThoroughfare)
        line1.add(text: placemark.thoroughfare, separatedBy: " ")
        
        var line2 = ""
        line2.add(text: placemark.locality)
        line2.add(text: placemark.administrativeArea, separatedBy: " ")
        line2.add(text: placemark.postalCode, separatedBy: " ")
        
        line1.add(text: line2, separatedBy: "\n")
        return line1
    }
    
    // MARK: - Sound Effect
    
    // Load sound file and place it into a new sound object
    func loadSoundEffect(_ name: String) {
        if let path = Bundle.main.path(forResource: name, ofType: nil) {
            let fileURL = URL(fileURLWithPath: path, isDirectory: false)
            let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
            
            if error != kAudioServicesNoError {
                print("Error code \(error) loading sound at path \(path)")
            }
        }
    }
    
    func unloadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0
    }
    
    func playSoundEffect() {
        AudioServicesPlaySystemSound(soundID)
    }
}
