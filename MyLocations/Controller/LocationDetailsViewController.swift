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

    // MARK: - Date Formatter

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

    // MARK: - Location Details View Controller

class LocationDetailsViewController: UITableViewController {
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var categoryName = "No Category"
    var date = Date()
    
    var dynamicHeight = CGFloat()
    var observer: Any!
    
     // Property Observer: if the image is changed, call show(image:image)
    
    var image: UIImage? {
        didSet{
            if let image = image {
                show(image: image)
            }
        }
    }
    
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
        
        // Change colour of table view and label colours
        tableView.backgroundColor = UIColor.black
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .white
        
        descriptionTextView.textColor = UIColor.white
        descriptionTextView.backgroundColor = UIColor.black
        
        addPhotoLabel.textColor = UIColor.white
        addPhotoLabel.highlightedTextColor = addPhotoLabel.textColor
        
        addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        addressLabel.highlightedTextColor = addressLabel.textColor
        
        if let location = locationToEdit{
            title = "Edit Location"
            if location.hasPhoto {
                if let theImage = location.photoImage {
                    show(image: theImage)
                }
            }
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
        
        listenForBackgroundNotification()
    }
    
    func string(from placemark: CLPlacemark) -> String {
        
        var line = ""
        line.add(text: placemark.subThoroughfare, separatedBy: " ")
        line.add(text: placemark.thoroughfare, separatedBy: ", ")
        line.add(text: placemark.locality, separatedBy: ", ")
        line.add(text: placemark.administrativeArea, separatedBy: ", ")
        line.add(text: placemark.postalCode, separatedBy: " ")
        line.add(text: placemark.country, separatedBy: ", ")
        return line
    }
        
        // MARK: - OLD CODE
//        var text = ""
//        if let s = placemark.subThoroughfare {
//            text += s + " "
//        }
//        if let s = placemark.thoroughfare {
//            text += s + ", "
//        }
//        if let s = placemark.locality {
//            text += s + ", "
//        }
//        if let s = placemark.administrativeArea {
//            text += s + " "
//        }
//        if let s = placemark.postalCode {
//            text += s + ", "
//        }
//        if let s = placemark.country {
//            text += s
//        }
//        return text
//        }
    
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
    
    // MARK: - UITableViewDelegate Methods.
    
    // Call just before cell becomes visible. Use this to customize cell and contents
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor = UIColor.black
        
        if let textLabel = cell.textLabel {
            textLabel.textColor = UIColor.white
            textLabel.highlightedTextColor = textLabel.textColor
        }
        
        if let detailLabel = cell.detailTextLabel {
            detailLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
            detailLabel.highlightedTextColor = detailLabel.textColor
        }
        
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        cell.selectedBackgroundView = selectionView
        
        if indexPath.row == 2 {
            let addressLabel = cell.viewWithTag(100) as! UILabel
            addressLabel.textColor = UIColor.white
            addressLabel.highlightedTextColor = addressLabel.textColor
        }
    }
    
    // Call when table view loads cells; use it to tell table view how tall each cell is
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch (indexPath.section, indexPath.row) {
            
        // Description Cell (section 0 row 0) has height 88
        case (0,0):
            return 88
       
        // Add Photo Cell (section 1). If there is no image then default height 44. If there is an image then set the height to the dynamic height
        // Ternary Conditional Operator => condition ? a : b. If condition is true then return a, otherwise b.
        case (1, _):
            return imageView.isHidden ? 44 : dynamicHeight + 20
            
        // Address Cell (section 2, row 2). Determine the width of the label (115 accounts for Address label and margins, and space between cells. Set height to 10000 then size to fit (use word-wrapping)
        // Change the x-position to fit the label to the right edge of the screen, and add margins (10 top and 10 bottom) for the final height
        case (2, 2):
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            return addressLabel.frame.size.height + 20
       
        // All other cells have default height 44 (Category, Latitude, Longitude, Date Cells)
            default:
                return 44
        }
    }
    
    // Limit ability of the user to tap rows; only first two sections can be tapped as the third section is read only.
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    // Open the keyboard if the first section and first row is tapped (Description). Perform camera function if the second section is tapped. 
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
            
        } else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            pickPhoto()
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    @IBAction func done() {
        
        // Set properties of the Location Object
        
        // Create a HUD by calling the HudView class' hud class function.
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        
        // Only ask Core Data for a new Location object if you don't already have one.
        // Create a location instance; use the init(context:) method  because this is a managed object. If just using Location() then managedObjectContext won't know about this new object.
        let location: Location
        if let temp = locationToEdit {
            hudView.text = "Updated"
            location = temp
        } else {
            hudView.text = "Tagged"
            location = Location(context: managedObjectContext)
            location.photoID = nil
        }
        
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        // Save image to the photoURL
        
        if let image = image {
            
            // If photo exists already keep the same ID. If adding a new photo then generate a new ID
            if !location.hasPhoto {
                print("*** LocationDetails VC, No photo found")
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            
            // Convert UIImage to JPEG format and return a Data object
            if let data = UIImageJPEGRepresentation(image, 0.5){
                
                // Save the Data object to the photoURL path
                print("*** Saving Data to \(location.photoURL)")
                do {
                    try data.write(to: location.photoURL, options: .atomic)
                } catch {
                    print("Error writing file: \(error)")
                }
            }
        }
        
        // Save the Managed Object Context
        
        // Call the free function afterDelay; executing the closure then results in self.dismiss.
        // Trailing Closure Syntax: you can place a closure behind a function call if it is the last parameter
        // Saving takes any objects that were added to the context or any managed objects that had contents changed and writes these into the data store.
        // Save method can fail; use a do-try-catch to catch any potential errors. If unable to perform the try, then Xcode skips that and jumps to the catch section.
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
    
    // Ask DateFormatter to turn the Date into a String, then returns that
    
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
    
    // Puts the image into imageView and gives it proper dimensions
    
    func show(image: UIImage) {
        
        let aspectRatio = image.size.width / image.size.height
        dynamicHeight = (CGFloat(260) / aspectRatio)
        
        imageView.image = image
        imageView.isHidden = false
        imageView.frame = CGRect(x: 10, y: 10, width: 260, height: dynamicHeight)
        addPhotoLabel.isHidden = true
    }
    
    // Dismiss alert or action sheet from screen when app is placed into background
    // Observer for UIApplicationDidEnterBackground notification; call closure when notification is received to dismiss image picker or action sheet
    
    func listenForBackgroundNotification() {
        
        // [weak self] is the capture list. self is captured with a weak reference (isntead of strong)
        observer = NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidEnterBackground, object: nil, queue: OperationQueue.main) { [weak self] _ in
            
            // Image Picker & Action Sheet are presented as modal view controllers. If presentedViewController is not nil then dismiss to close the modal screen.
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil {
                strongSelf.dismiss(animated: false, completion: nil)
            }
            strongSelf.descriptionTextView.resignFirstResponder()
            }
        }
    }
    
    deinit {
        print("*** deinit \(self)")
        NotificationCenter.default.removeObserver(observer)
    }
}

// MARK: - UIImagePickerController & NavigationController

// Create the ImagePickerController, set properties, the delegate, and then present it

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    // Invoke when user selects a photo in the image picker
    // Info dictionary contains data describing the image the user picked. Use the UIImagePickerControllerEditedImiage key to retrieve the UIImage object and store it in the image variable
    // If there is an image that is not nil, then call show(image) to put it in the Add Photo Cell
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        tableView.reloadData()
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // If a camera is present then call give options to take a photo or show photo. Otherwise only allow chooseFromLibrary action.
    
    func pickPhoto() {
        // Uncomment to test actionSheet. if true || UIImagePickerController.isSourceTypeAvailable(.camera){
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in self.takePhotoWithCamera()})
        alertController.addAction(takePhotoAction)
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: {_ in self.choosePhotoFromLibrary()})
        alertController.addAction(chooseFromLibraryAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = MyImagePickerController()
        imagePicker.view.tintColor = view.tintColor
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func takePhotoWithCamera() {
        let imagePicker = MyImagePickerController()
        imagePicker.view.tintColor = view.tintColor
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
}
