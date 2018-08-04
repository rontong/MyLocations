//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Ronald Tong on 3/7/18.
//  Copyright © 2018 StokeDesign. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

// Private global constant. Only performed the first time dateFormatter global is used in the app. Cannot be used outside of this swift file but lives outside of the class.
// Utilises a closure {}() to create the new object AND set properties in one go
// Code inside the closure creates and initializes the DateFormatter object, then returns DateFormatter to be put into instance dateFormatter

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    print("*** Date Formatting Done")
    return formatter
}()

class LocationDetailsViewController: UITableViewController {
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var categoryName = "No Category"
    var date = Date()

    // Property Observer: if a variable has didSet then code within the block is performed whenever you put a new value into the variable
    
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    
    var descriptionText = ""
    
    var managedObjectContext: NSManagedObjectContext!
    
    // If locationToEdit is not nil then set the title to edit location. locationToEdit is optional as it will be nil in adding mode
    // Target Actions: "action: #selector" tells the object to call the #selector() method whenever a gesture happens
    // A tap in the table view prompts the gestureRecognizer to call the hideKeyboard action.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let location = locationToEdit{
            title = "Edit Location"
        }
        
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        dateLabel.text = format(date: date)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        if let s = placemark.subThoroughfare {
            text += s + " "
        }
        if let s = placemark.thoroughfare {
            text += s + ", "
        }
        if let s = placemark.locality {
            text += s + ", "
        }
        if let s = placemark.administrativeArea {
            text += s + " "
        }
        if let s = placemark.postalCode {
            text += s + ", "
        }
        if let s = placemark.country {
            text += s
        }
        return text
        }
    
    // gestureRecognizer.location returns a CGPoint (struct) that contains an x and y position
    // Determine the indexPath at the selected point; if that indexPath is not the text view (section 0 and row 0) then return and do not hide the keyboard. Otherwise hide the keyboard.
    // If the user taps between two sections the indexPath could be nil; therefore it has to be optional
    // Safe to force unwrap here due to the short-circuiting of the && operator. If indexPath is nil then everything behind the first && is ignored. 
    
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        
        descriptionTextView.resignFirstResponder()
    }
    
    // MARK: - UITableViewDelegate. Called when table view loads cells; use it to tell table view how tall each cell is
    // Determine the width of the label (115 accounts for Address label and margins, and space between cells. Set height to 10000 then size to fit (use word-wrapping)
    // Change the x-position to fit the label to the right edge of the screen, and add margins (10 top and 10 bottom) for the final height
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 88
        } else if indexPath.section == 2 && indexPath.row == 2 {
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            return addressLabel.frame.size.height + 20
        } else {
            return 44
        }
    }
    
    // Limits ability of the user to tap rows; only first two sections can be tapped as the third section is read only.
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
    }
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // Creates a HUD by calling the HudView class' hud class function.
    
    // Only ask Core Data for a new Location object if you don't already have one. 
    
    // Create a location instance; use the init(context:) method  because this is a managed object. If just using Location() then managedObjectContext won't know about this new object.
    // Set properties to the location instance, then call the save method
    // Saving takes any objects that were added to the context or any managed objects that had contents changed and writes these into the data store.
    // Save method can fail; use a do-try-catch to catch any potential errors. If unable to perform the try, then Xcode skips that and jumps to the catch section. 
    
    // Calls the free function afterDelay; executing the closure then results in self.dismiss.
    // Trailing Closure Syntax: you can place a closure behind a function call if it is the last parameter
    
    @IBAction func done() {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        
        let location: Location
        if let temp = locationToEdit {
            hudView.text = "Updated"
            location = temp
        } else {
            hudView.text = "Tagged"
            location = Location(context: managedObjectContext)
        }
        
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        do {
            try managedObjectContext.save()
        afterDelay(0.6) {self.dismiss(animated: true, completion: nil)
            }
            
        } catch {
                fatalCoreDataError(error)
        }
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    // Asks DateFormatter to turn the Date into a String, then returns that
    
    func format(date: Date) -> String{
        return dateFormatter.string(from: date)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    // Unwind segue needs to define an action method with a UIStoryboardSegue parameter. Use with prepare(for segue) in the source VC to send data. 
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
}
