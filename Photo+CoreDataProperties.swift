//
//  Photo+CoreDataProperties.swift
//  virtualTourist
//
//  Created by Nikki L on 8/13/17.
//  Copyright © 2017 Nikki. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var mediaURL: String?
    @NSManaged public var imageData: NSData?
    @NSManaged public var photoName: String?
    @NSManaged public var pin: Pin?
    /* "@NSManged" . The @NSManaged attribute is similar to the @dynamic attribute in Objective-C. The @NSManaged attribute tells the compiler that the storage and implementation of these properties will be provided at runtime. While this may sound great, Apple's documentation clearly states that @NSManaged should only be used in the context of Core Data.
    
    If this sounds a bit confusing, then remember that @NSManaged is required for Core Data to do its work and the @NSManaged attribute should only be used for NSManagedObject subclasses. */

}
