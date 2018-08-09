//
//  LocationCellTableViewCell.swift
//  MyLocations
//
//  Created by Ronald Tong on 7/7/18.
//  Copyright © 2018 StokeDesign. All rights reserved.
//

import UIKit

class LocationCell : UITableViewCell {

    // Change appearance of cells in the tableView
    // awakeFromNib => every object from a storyboard has this method. Use this to customize appearance.
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.black
        descriptionLabel.textColor = UIColor.white
        descriptionLabel.highlightedTextColor = descriptionLabel.textColor
        addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        addressLabel.highlightedTextColor = addressLabel.textColor
        
        // Create a new UIView with dark gray colour, place it over the top of the cell's background when cell is tapped
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        selectedBackgroundView = selectionView
        
        // Give imageView rounded corners with radius 1/2 the width of the image (to make a circle). clipsToBounds ensures imageView does not draw outside the corners. separatorInset moves separator lines so there are no lines between thumbnail images
        photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2
        photoImageView.clipsToBounds = true
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
        
        // Uncomment to debug sizing of labels
//        descriptionLabel.backgroundColor = UIColor.purple
//        addressLabel.backgroundColor = UIColor.purple
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    func configure(for location: Location) {
        if location.locationDescription.isEmpty {
            descriptionLabel.text = "(No Description)"
        } else {
            descriptionLabel.text = location.locationDescription
        }
        
        if let placemark = location.placemark {
            var text = ""
            
            text.add(text: placemark.subThoroughfare)
            text.add(text: placemark.thoroughfare, separatedBy: " ")
            text.add(text: placemark.locality, separatedBy: ", ")
            addressLabel.text = text
        } else {
            addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
        }
        photoImageView.image = thumbnail(for: location)
    }
    
    // Set thumbnail for the Location Cell
    func thumbnail(for location: Location) -> UIImage {
        
        // If location has a photo and location.photoImage can be unwrapped, return the unwrapped image
        // ALT: if location.hasPhoto { if let image = location.photoImage { return image } }
        if location.hasPhoto, let image = location.photoImage {
            return image.resizedImage(withBounds: CGSize(width: 52, height: 52))
        }
        
        // If there is no image then use the No Photo asset
        return UIImage(named: "No Photo")!
    }
}
