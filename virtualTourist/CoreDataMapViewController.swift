//
//  CoreDataMapViewController.swift
//  virtualTourist
//
//  Created by Nikki L on 8/17/17.
//  Copyright © 2017 Nikki. All rights reserved.
//

import UIKit
import CoreData
import MapKit

// class MapViewController: UIViewController, MKMapViewDelegate {
class CoreDataMapViewController: UIViewController, MKMapViewDelegate {
    
    // Part 1 - MARK - Properties
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            /* Whenever the fetchedResultsController changes, we execute the search and
               reload the Map */
            fetchedResultsController?.delegate = self
            
            
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
