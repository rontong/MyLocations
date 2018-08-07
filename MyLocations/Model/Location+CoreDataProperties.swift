//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by Ronald Tong on 5/7/18.
//  Copyright © 2018 StokeDesign. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation


extension Location {

    // Any object managed by Core Data has to be declared as @NSManaged
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var date: Date
    @NSManaged public var locationDescription: String
    @NSManaged public var category: String
    @NSManaged public var placemark: CLPlacemark?
    
    // Declare as NSNUmber (instead of Int) as Core Data is Obj-C framework. Int cannot be optional in Objective-C
    @NSManaged public var photoID: NSNumber?

}
