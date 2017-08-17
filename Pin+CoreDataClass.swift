//
//  Pin+CoreDataClass.swift
//  virtualTourist
//
//  Created by Nikki L on 8/13/17.
//  Copyright © 2017 Nikki. All rights reserved.
//

import Foundation
import CoreData

// MARK - Pin: NSManagedObject
@objc(Pin)
public class Pin: NSManagedObject {

    // Insert code here to add functionality to your managed object subclass - 
    // MARK: Initializer
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
    // should not have "text" right? because entity Pin DOESN"T have "text"....??? ask mentor
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context)
        {
            self.init(entity: ent, insertInto: context)
            self.creationDate = Date() // Date"()" automatically created date when pin is created
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Unable to find Entity name!")
        }
    } // END of convenience init
}







