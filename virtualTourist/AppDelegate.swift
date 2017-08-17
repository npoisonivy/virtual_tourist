//
//  AppDelegate.swift
//  virtualTourist
//
//  Created by Nikki L on 7/14/17.
//  Copyright © 2017 Nikki. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let stack = CoreDataStack(modelName: "Model")!

    func removeDataForDebug() {
        
        // Remove previous stuff (if any) - it delects data but not the tables
        do {
          try stack.dropAllData()
        } catch {
            print("Error dropping all objects in DataBase")
        }
    }
    
    
    
// This is where need to modify code
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print("App Delegate: will finish launching")
        
        checkIfFirstLaunch() // if 1st launch - make sure UserDefault's array "savedMapRegion" has stuff in it - @ mapVC, need to display this "savedMapRegion" on the map - this sets the zoom level!
  
        return true
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Obtain the location of Coredata -> and I use it to find core data location in finder
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print(paths[0])
        
        // call to remove all previous data - for easier debugging purpose
        removeDataForDebug()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        
        // add user's zoom level, map center here too right?
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        
        /* self.saveContext() ???  */
    }

    // MARK: - Func to check app ever launched before
    /* MARK - [ ] if launched before - retrieve the previous set value of zoom level + center of the map
     [ ] else , not launched before - set the brand new value of what zoom level should be*/
    func checkIfFirstLaunch() {
        // Launched before
        if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") { // Don't I need to set its bool to FALSE VERY FIRST TIME??? - Ans: NO, as by default, false is returned.
            // Do NOTHING - code @ mapVC will take care of retrieving the new value when user zooms OR retrieving the OLD value when user NEVER zooms
        } else { /* first time launching */
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            // SET initial zoom level - meaning: span + latitude/ longitude (I hv to make it up as there is no user's input yet
            let regionToSave = [
                // pre-set lat/ lon Grand Teton
                "mapRegionLat": 43.790428, // Up to me - when user never adds any pin before...
                "mapRegionLon": -110.681763,
                
                // span
                "latDelta": 0.075,
                "lonDelta": 0.075
            ]
            
            UserDefaults.standard.set(regionToSave, forKey: "savedMapRegion")
            UserDefaults.standard.synchronize() // see quick help for explanation
        }
    } // END of func checkIfFirstLaunch() {
}

