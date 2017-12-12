//
//  CoreDataStack.swift
//
//  Created by Nikki L on 8/13/17.
//  Copyright © 2017 udacity.com. All rights reserved.
//

import CoreData
import Foundation

/* FROM UDACITY's TEMPLATE */
/* MARK: - CoreDataStack - this file init model of Model.xcdatamodeId - creates Context and add to Persistent Store coordinator, Add Persistent Store to Persistent Store coordinator. And handle save() when detecting change in context.
 */

// should make a singleton with class and not struct - reason - https://stackoverflow.com/questions/36788169/whats-the-difference-between-struct-based-and-class-based-singletons


// set up class func "sharedInstance" here
// I just change "Struct CoreDataStack to class CoreDataStack" ??? ask mentor if that is okay. I changed it because sharedInstance allow mutation only if its a CLASS but not "Struct"!
class CoreDataStack {
    
    class func sharedInstance() -> CoreDataStack {
        struct Singleton {
            static var sharedInstance = CoreDataStack(modelName: "Model")!
        }
        return Singleton.sharedInstance
    }
    
//    class func sharedInstance() -> UdacityClient {
//        struct Singleton {
//            static var sharedInstance = UdacityClient()
//        }
//        return Singleton.sharedInstance
//    }
    
    // MARK: Properties
    
    private let model: NSManagedObjectModel
    internal let coordinator: NSPersistentStoreCoordinator
    private let modelURL: URL
    internal let dbURL: URL
    let context: NSManagedObjectContext
    
    // MARK: Initializers
    // When it's declared, it will search the name "modelName" in the system - if name does not exist in Core Data, it won't work - Ex: there is only "Model.xcdatamodeld" - it's only "Model"
    
    init?(modelName: String) {
        
        // Assumes the model is in the main bundle - "momd" refers to "Model.xcdatamodeId" data model we added
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("Unable to find \(modelName)in the main bundle")
            return nil
        }
        self.modelURL = modelURL
        
        // Try to create the model from the URL
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model
        
        // Create the store coordinator for the model "Model.xcdatamodeId"
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // create a context and add connect it to the coordinator - The coordinator provides the managed object model and handles persistency. Note that multiple contexts can share a coordinator. Persistent Store Coordinator mediates between the persistent stores and the managed object contexts.
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        
        // Add a SQLite store located in the documents folder
        let fm = FileManager.default
        
        guard let docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to reach the documents folder")
            return nil
        }
        
        self.dbURL = docUrl.appendingPathComponent("model.sqlite")
        print("dburl is...\(self.dbURL)")
        
        // Options for migration
        let options = [NSInferMappingModelAutomaticallyOption: true,NSMigratePersistentStoresAutomaticallyOption: true]
        
        do {
            // Add Persistent Store -> to Persistent Store Coordinator
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: options as [NSObject : AnyObject]?)
        } catch {
            print("unable to add store at \(dbURL)")
        }
    }
    
    // MARK: Utils
    // Add Persistent Store -> to Persistent Store Coordinator
    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options : [NSObject:AnyObject]?) throws {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
    }
}

// MARK: - CoreDataStack (Removing Data) - dropAllData() - delete all the objects inside of your sqlite store - but it won’t delete the files - it just empties the tables. This is useful while you’re developing. < good for debugging period >

internal extension CoreDataStack  {
    
    func dropAllData() throws {
        // delete all the objects in the db. This won't delete the files, it will
        // just leave empty tables.
        try coordinator.destroyPersistentStore(at: dbURL, ofType:NSSQLiteStoreType , options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
    }
}

// MARK: - CoreDataStack (Save Data)

extension CoreDataStack {
    
    func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    func autoSave(_ delayInSeconds : Int) {
        
        if delayInSeconds > 0 {
            do {
                try saveContext()
                print("Autosaving")
            } catch {
                print("Error while autosaving")
            }
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.autoSave(delayInSeconds)
            }
        }
    }
    
    
    // COPIED FROM APPDELEGATE - auto generate when creating DataModel to Project
    // MARK: - Core Data stack
    /*
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "virtualTourist")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }() // END of "lazy var persistentContainer: NSPersistentContainer = {"
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    } // END of func saveContext () {

*/
}



