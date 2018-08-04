//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Ronald Tong on 5/7/18.
//  Copyright © 2018 StokeDesign. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

class LocationsViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    
    var locations = [Location]()
    
    // Ask the managed object context for a list of location objects in the data store, sorted by date
    // Create a NSFetchRequest object that describes the search parameters for objects to be retrieved from the data store. Using <Location> tells NSFetchRequests to return an array of location objects
    // Tell fetchRequest to look for location entities, then sort by date
    // Tell the context to execute the fetch() method using fetchRequest parameters. Fetch() returns an array with sorted objects or throws an error.
    // This assigns the results of fetch() to the locations instance variable
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest<Location>()
        let entity = Location.entity()
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            locations = try managedObjectContext.fetch(fetchRequest)
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation"{
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let location = locations[indexPath.row]
                controller.locationToEdit = location
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        
        let location = locations[indexPath.row]
        cell.configure(for: location)
        
        return cell
        
    }
    
}
