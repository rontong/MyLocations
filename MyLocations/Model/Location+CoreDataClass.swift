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
    // Use read-only computed properties. These do not store value in memory. When the property is accessed the logic is performed. Read-onlye, cannot give the property a new value using assignment operator (=)
    
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
}
