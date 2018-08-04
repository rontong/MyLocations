//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Ronald Tong on 4/7/18.
//  Copyright © 2018 StokeDesign. All rights reserved.
//

import Foundation
import UIKit

class CategoryPickerViewController: UITableViewController {
    
    var selectedCategoryName = ""
    
    let categories = ["No Category", "Apple Store", "Bar", "Bookstore", "Club", "Grocery Store", "Historic Building", "House", "Icecream Vendor", "Landmark", "Park"]
    
    var selectedIndexPath = IndexPath()
    
    // Loop through the array of categories and compare each to the selectedCategoryName. If there is  match, create an index-path object and store it in selectedIndexPath. Break the loop once a match is found.
    // Looks at categories[0], then categories [1] and so on to see if it matches selectedCategoryName (sent via the segue)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<categories.count {
            if categories[i] == selectedCategoryName {
                selectedIndexPath = IndexPath(row: i, section: 0)
                break
            }
        }
    }
    
    // Look at the selected indexPath and put the category name into the selectedCategoryName property
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell) {
                selectedCategoryName = categories[indexPath.row]
            }
        }
    }
    
    
    // MARK: = UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let categoryName = categories[indexPath.row]
        cell.textLabel!.text = categoryName
        
        if categoryName == selectedCategoryName {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    // Removes checkmark from the previously selected cell (selectedIndexPath from for in loop) and add a checkmark to the row that is tapped
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != selectedIndexPath.row {
            if let newCell = tableView.cellForRow(at: indexPath){
                newCell.accessoryType = .checkmark
            }
            if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
                oldCell.accessoryType = .none
            }
            selectedIndexPath = indexPath
        }
    }
    
}
