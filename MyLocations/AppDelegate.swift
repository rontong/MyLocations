//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Ronald Tong on 1/7/18.
//  Copyright © 2018 StokeDesign. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: - Create a Core Data Stack to load the data model;
    // 1. Create an NSManagedObjectModel from Core Data model; this represents the model during runtime. (See swift files in Model)
    // 2. Create an NSPersistentStoreCoordinator object in charge of the SQLite database. (lazy var persistentContainer)
    // 3. Create the NSManagedObjectContext object and connect it to the store coordinator. (lazy var managedObjectContext)
    
    // Lazy Loading (lazy): code is not executed until it is asked for
    // Create an instance variable persistentContainer with value {closure}. Parentheses at the end of the closure invoke it immediately (unlike a normal closure)
    // Create a NSPersistentContainer object named "DataModel" and tell it to load data from the database into memory ( loadPersistentStores() )
    // Another closure is invoked when persistent container is done loading data; prints any errors and terminates the app
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: {
            storeDescription, error in
            if let error = error {
                fatalError("Could load data store: \(error)")
            }
        })
        return container
    }()
    
    // MARK: - Scratchpad (NSManagedObjectContext): object used to talk to Core Data. Every object that needs to do something with CoreData needs a reference to the NSManagedObjectContext object.
    // Ask persistentContainer for viewContext to get the NSManagedObjectContext
    
    lazy var managedObjectContext: NSManagedObjectContext = self.persistentContainer.viewContext
    
    // Give the currentLocationVC the managedObjectContext reference to talk to CoreData. Get a reference to currentLocationVC by finding UITabBarController and looking at its viewControllers array
    // Give the locationsVC the managed Object Context reference as well
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let tabBarController = window!.rootViewController as! UITabBarController
        if let tabBarViewControllers = tabBarController.viewControllers {
            
            let currentLocationViewController = tabBarViewControllers[0] as! CurrentLocationViewController
            currentLocationViewController.managedObjectContext = managedObjectContext
            
            let navigationController = tabBarViewControllers[1] as! UINavigationController
            let locationsViewController = navigationController.viewControllers[0] as! LocationsViewController
            locationsViewController.managedObjectContext = managedObjectContext
            
            let _ = locationsViewController.view
        }
        print(applicationDocumentsDirectory)
        listenForFatalCoreDataNotifications()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    // Listens for fatalCoreDataError() message
    // NotificationCenter will perform the {closure} whenever the MyManagedObjectContextSaveDidFailNotification message is sent
    // Creates a UIAlertController to show the message, adds an action for the alert's OK button
    // Clicking the action will trigger a closure which uses an NSException to terminate the app
    // Show the alert in the current visible view controller (using viewControllerForShowingAlert)
    
    func listenForFatalCoreDataNotifications() {
        NotificationCenter.default.addObserver(forName: MyManagedObjectContextSaveDidFailNotification, object: nil, queue: OperationQueue.main, using: {notificcation in
            
            let alert = UIAlertController(
                title: "Internal Error",
                message: "There was a fatal error in the app and it cannot continue. \n\n" + "Press OK to terminate the app. Sorry for the inconvenience.",
                preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                let exception = NSException(name: NSExceptionName.internalInconsistencyException, reason: "Fatal Core Data error", userInfo: nil)
                exception.raise()
            }
            alert.addAction(action)
            self.viewControllerForShowingAlert().present(alert, animated: true, completion: nil)
        })
    }

    func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController = self.window!.rootViewController!
        if let presentedViewController = rootViewController.presentedViewController {
            return presentedViewController
        } else {
            return rootViewController
        }
    }
}

