//
//  Functions.swift
//  MyLocations
//
//  Created by Ronald Tong on 5/7/18.
//  Copyright © 2018 StokeDesign. All rights reserved.
//

import Foundation
import Dispatch

// Global Constant to locate the app's Documents directory.
// Uses a closure to provide code that initializes the constant. Creates applicationDocumentsDirectory of type URL with value {closure}. Avoid needing to use an init. 

let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()

// Global Function that handles fatal Core Data errors
// Uses NotificationCenter to post a notification. Defines a custom notification called MyManagedObjectContextSaveDidFailNotification
// Sends out an error but needs another object to listen for the notification and handle the error -> AppDelegate

let MyManagedObjectContextSaveDidFailNotification = Notification.Name(rawValue: "MyManagedObjectContextSaveDidFailNotification")

func fatalCoreDataError(_ error: Error) {
    print(" *** Fatal error: \(error)")
    NotificationCenter.default.post(name: MyManagedObjectContextSaveDidFailNotification, object: nil)
}

// Free Function can be used from anywhere in code (not a method inside an object)
// Utilises Grand Central Dispatch framework (asynchronous tasks) to close LocationDetailsVC after x seconds. 
// -> () takes a closure with no arguments and no return value
// @escaping is necessary for closures that are not performed immediately

func afterDelay(_ seconds: Double, closure: @escaping () -> ()) { DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)}


