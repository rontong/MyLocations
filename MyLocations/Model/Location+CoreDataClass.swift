//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by Ronald Tong on 5/7/18.
//  Copyright © 2018 StokeDesign. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

public class Location: NSManagedObject, MKAnnotation {

    // MKAnnotation protocol requires the class to implement a coodinate, title, and subtitle
    // Use read-only computed properties. These do not store value in memory. When the property is accessed the logic is performed. Read-only, cannot give the property a new value using assignment operator (=)
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    public var title: String? {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }
    
    public var subtitle: String? {
        return category
    }
    
    // Determine whether Location object has an associated photo
    public var hasPhoto: Bool {
        return photoID != nil
    }
    
    // Compute the URL to the JPEG file. JPEGs save inside app Document Directory
    public var photoURL: URL {
        
        // Assertion => debugging tool to check code always does something valid. Disable before uploading to App Store
        // If app asks for a Location object without giving a photoID then it will crash with error "No photo ID set"
        assert(photoID != nil, "No photo ID set")
        
        let filename = "Photo-\(photoID!.intValue).jpg"
        return applicationDocumentsDirectory.appendingPathComponent(filename)
    }
    
    // Load the image file and return a UIImage object
    public var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoURL.path)
    }
    
    // Generate unique ID for each location object
    class func nextPhotoID() -> Int {
        print("*** Generating New Photo ID")
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "PhotoID")
        userDefaults.set(currentID + 1, forKey: "PhotoID")
        userDefaults.synchronize()
        
        // DEBUG
        let printKey = userDefaults.data(forKey: "PhotoID")
        print("*** CurrentID is \(currentID), User Defaults for key PhotoID: \(printKey)")
       
        return currentID
    }
    
    //Remove photo file at photoURL
    func removePhotoFile() {
        if hasPhoto {
            do {
                try FileManager.default.removeItem(at: photoURL)
            } catch {
                print("Error removing file: \(error)")
            }
        }
    }
}
