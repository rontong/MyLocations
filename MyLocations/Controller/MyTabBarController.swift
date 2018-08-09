//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Ronald Tong on 9/8/18.
//  Copyright © 2018 StokeDesign. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {
    
    // Override preferredStatusBarStyle to set all status bar text to white (all view controllers)
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // Return nil to make tab bar controller look at its own preferredStatusBarStyle instead of those from other view controllers
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return nil
    }
}
