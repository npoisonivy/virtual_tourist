//
//  Photo+CoreDataClass.swift
//  virtualTourist
//
//  Created by Nikki L on 8/13/17.
//  Copyright © 2017 Nikki. All rights reserved.
//

import Foundation
import CoreData

// MARK - Photo: NSManagedObject
@objc(Photo)
public class Photo: NSManagedObject { // Photo is a child class of NSManagedObject
    //  an NSManagedObject instance contains the information of a row in a database table. Each ManagedObject instance associated w/ an instance of NSEntityDescription & NSManagedObjectContext
    // Insert code here to add functionality to your managed object subclass - Example - adding EntityDescription + NSManagedObjectContext
    
    // MARK - Initializer - create new instance of Photo
    /* ??? am i missing the text input ?? - ask mentor .. i don't add text because "Photo" do not have property "text"...
    convenience init(text: String = "New Note", context: NSManagedObjectContext) */
    convenience init(mediaURL: String, photoName: String, context: NSManagedObjectContext) {
        // NSManagedObjectContext - a managed object belongs to, monitors this managed object for changes.
        // 1. create an instance of NSEntityDescription class - we pass the name of entity that we want to create a MANAGED OBJECT for, "Photo", and also pass an context (=NSManagedObjectContext) instance --> this tells Core Data where to find the data model for this entity - "Photo"
        // a managed object context is tied to a persistent store coordinator and a persistent store coordinator keeps a reference to a data model. When we pass in a managed object context, Core Data asks its persistent store coordinator for its data model to find the entity we're looking for.
        
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) //NSEntityDescription has entity, attributes & r/s
        {
            // 2. A managed object ("Photo" here) - is associated with an entity description and it lives in a managed object context, which is why we tell Core Data which managed object context the new managed object "Photo" should be linked to. Now, we've created a new Photo Object!
            self.init(entity: ent, insertInto: context)
            // does this look alright ? ask Mentor!
            self.creationDate = Date() // Date"()" - auto created date upon Photo creation
            self.mediaURL = mediaURL
            // self.imageData = imageData // when ManageObject of Photo is initialized - i may not have imageData ready , how should I write this? -> ?? self.imageData = "NSData()" ??? mentor - her ans: remove this as I was right, it wasn't ready @ inti, so we don't need it here.
            self.photoName = photoName
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
    // Photos data returned from getPhotoArrayByRandPage - we need to save those photo to CoreData by creating Photo: NSManagedObject
    class func createPhotoInstance(_ mediaURL: String, _ photoName: String, _ currentPin: Pin, _ context: NSManagedObjectContext) -> Void {
        let newPhoto = Photo(mediaURL: mediaURL, photoName: photoName, context: context) // Mentor... not this stack or need to declare stack @ this file?
        // currentPin.photo = newPhoto - cannot assign a photo to a NSSET, , need to add object to collection. otherwise, the photo is not added to the SET.
        newPhoto.pin = currentPin // adding photo to the NSSET by adding object to collection
        
        // save it to coreData - ask mentor... WHERE TO SAVE???
        // now - saveContxt with do/ catch block - industrial standard to avoid app crashing
        /*
            do {
                try stack.saveContext()
            } catch {
                print("Saved failed!")
            }
         */
        
    }
}






















