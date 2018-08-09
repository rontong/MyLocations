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
    
    // Instantiate a fetchedResultsController with a fetch Request and set the delegate. If any Location objects change after the initial fetch, the delegate methods are called to notify you of changes
    // Fetch request describes the parameters for objects to be retrieved from the data store
    // Make a fetch request with an entity and sort descriptors, only fetching 20 objects at a time, <Location> tells NSFetchRequest to return an array of location objects
    // Make the fetchedResultsController using the fetch request, context, and a unique cache name
    
    lazy var fetchedResultsController: NSFetchedResultsController<Location> = {
        
        let fetchRequest = NSFetchRequest<Location>()
        
        let entity = Location.entity()
        fetchRequest.entity = entity
        
        let sortDescriptor1 = NSSortDescriptor(key: "category", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "category", cacheName: "Locations")
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable deletion by tapping a NavBar Edit button
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        performFetch()
        
        // Tableview colour set to black. Note this does not change the cells (use LocationCell.swift to edit cells)
        tableView.backgroundColor = UIColor.black
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .white
        
        tableView.sectionHeaderHeight = 28
    }
    
    func performFetch(){
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    // Invoke when the view controlled is destroyed. Set the delegate to nil when the FetchedResultsController is no longer needed
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    // Invoked when user taps a row in the Locations screen. Deterine which location object belongs to the row and places it in the locationToEdit property
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation"{
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let location = fetchedResultsController.object(at: indexPath)
                controller.locationToEdit = location
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    
    // Delegate method is called for each section in the table view
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Create a label for the section
        let labelRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 14, width: 300, height: 14)
        let label = UILabel(frame: labelRect)
        label.font = UIFont.boldSystemFont(ofSize: 11)
        label.text = tableView.dataSource!.tableView!(tableView, titleForHeaderInSection: section)
        label.textColor = UIColor(white: 1.0, alpha: 0.4)
        label.backgroundColor = UIColor.clear
        
        // Create a 1-pixel view as a separator line
        let separatorRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 0.5, width: tableView.bounds.size.width - 15, height: 0.5)
        let separator = UIView(frame: separatorRect)
        separator.backgroundColor = tableView.separatorColor
        
        // Create a container view to hold these two subviews
        let viewRect = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.sectionHeaderHeight)
        let view = UIView(frame: viewRect)
        view.backgroundColor = UIColor(white: 0, alpha: 0.85)
        view.addSubview(label)
        view.addSubview(separator)
        return view
    }
    
    // MARK: - UITableViewDataSource
    
    // .sections returns an array of NSFetchedResultsSectionInfo objects that describe each section of the table view
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }    
    
    // Ask the fetchedResultsController for the object at the requested index-path
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        
        let location = fetchedResultsController.object(at: indexPath)
        cell.configure(for: location)
        
        return cell
        
    }
    
    // Ask the fetchedResultsController for the number of sections and title for each section
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name.uppercased()
    }
    
    // Implement (commit, for Row) to enable swipe-to-delete function
    // Tell the context to delete the object. This triggers fetchedresultsController to send a notification to the delegate. The delegate will then remove the row from the table
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      
        if editingStyle == .delete {
            let location = fetchedResultsController.object(at: indexPath)
            
            // Remove photo file on the location object, then delete location object from Core Data context
            location.removePhotoFile()
            managedObjectContext.delete(location)
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
    
}

    // MARK: - Delegate functions for the NSFetchedResultsController
    // NSFetchedResultsController will invoke these mothods to notify that objects have been inserted, removed or updated. The delegate methods are then used to call UITableView methods

extension LocationsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            print("*** NSFetchedResultChangeInsert (object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        case .delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
                let location = controller.object(at: indexPath!) as! Location
                
                cell.configure(for: location)
            }
            
        case .move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
            
        case .insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            
        case .delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            
        case .update:
            print("*** NSFetchedResultsChangeUpdate (section)")
            
        case .move:
            print("*** NSFetchedResultsChangeMove (section)")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}
