//
//  MapViewController.swift
//  virtualTourist
//
//  Created by Nikki L on 7/14/17.
//  Copyright © 2017 Nikki. All rights reserved.

import UIKit
import MapKit
import CoreData
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView! // it does not have MKMapViewDelegate till adding "self.mapView.delegate = self  // self = MapVC.swift"
    
    var annotations = [MKPointAnnotation]() // store all annotations/ pin locations frovarhe mapView
    var lat: Double = 0.0
    var lon: Double = 0.0
    
    let stack = CoreDataStack.sharedInstance()
    
    var currentPinObject:Pin? //  Error raised if -> var currentPinObject = Pin
    
    override func viewWillAppear(_ animated: Bool) { // ask mentor??? do i need to keep this "_ animated: Bool? - Nikki: I think we should?
        
        super.viewWillAppear(animated)
        FlickrConvenience.sharedInstance().totalPages = nil // viewWillAppear is called everytime mapView is shown
   
        // add all the pins from Core Data
        displayAllAnnotationsFromCoreData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self // self = MapViewController.swift -> since MapVC has "MKMapViewDelegate" -> self can call mapview's delegate func, now, assign property "mapView" this ability too (tableview has built-in, no need to do this part)
        
        // Mentor advises me to read more about tap/ other geseture recognizzer!
        // MARK - Create UILongPressGestureRecognizer
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRecogniser) // registered -> call .handleLongPress when user perform the action
        
        // change (VAR) properties of zoom level - use mapviewdelegate func -> detecting pinching motion - when REGION of the map is changed.
        // (VAR) center of the map - depends on where the pin is at -> "span" around
        // access to self.lon & self.lat - this is diff than lon/ lat from <#T##centerCoordinate: CLLocationCoordinate2D##CLLocationCoordinate2D#>, right??? ask mentor!
        
        // should retrieve "savedMapRegion" to display zoom level
        // 0. get the value of pre-set "regionToSave"
        // 1. convert elements from key "savedMapRegion" (array)
        // 2. call this to display zoom level - mapView.region = MKCoordinateRegionMake(<#T##centerCoordinate: CLLocationCoordinate2D##CLLocationCoordinate2D#>, <#T##span: MKCoordinateSpan##MKCoordinateSpan#>)
        
        // when viewDidLoad - only 2 scenerios - A. 1st launch, so i need to retrieve what was saved to "savedMapRegion" B. not 1st lauch, that will be taken care of , as new value has already been set!
        
        // 0. get the value of pre-set "regionToSave" @ AppDelegate.swift
        if let savedRegion = UserDefaults.standard.object(forKey: "savedMapRegion") as? [String: Double] {
            // 1. convert elements from key "savedMapRegion" (array)
            let center = CLLocationCoordinate2D(latitude: savedRegion["mapRegionLat"]! , longitude: savedRegion["mapRegionLon"]!)
            let span = MKCoordinateSpan(latitudeDelta: savedRegion["latDelta"]! , longitudeDelta: savedRegion["lonDelta"]!)
            print("span is \(span.latitudeDelta) & \(span.longitudeDelta)")
            
            // 2. mapView.region = MKCoordinateRegionMake(<#T##centerCoordinate: CLLocationCoordinate2D##CLLocationCoordinate2D#>, <#T##span: MKCoordinateSpan##MKCoordinateSpan#>)
            // mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: savedRegion["mapRegionLat"]! , longitude: savedRegion["mapRegionLon"]!), MKCoordinateSpan(latitudeDelta: savedRegion["latDelta"]! , longitudeDelta: savedRegion["lonDelta"]!))
            mapView.region = MKCoordinateRegionMake(center, span)
            print("current display is from array of savedRegion... \(savedRegion)")
            // above code works!
            
            /* OR:
             let CoordinateRegion = MKCoordinateRegionMake(center, span)
             // mapView.setRegion(region: MKCoordinateRegion, animated: <#T##Bool#>)
             mapView.setRegion(CoordinateRegion, animated: true)
             // setRegion - Changes the currently visible region and optionally animates the change.
             // above code works too! */
            
        } // END of "if let savedRegion =" - if let for: make sure "savedRegion" != nil
        
    } // END of viewDidLoad()
    
    // Part 1 - MARK - Properties
    // this NSFetchedResultsController works with UI collection view and table view.
    // <NSFetchRequestResult> is the result type
    // this part is not neccessary because there is no use of Table / Collection view - we only have mapView!
    
    //NSFetchRequest
    //fect the data using context
    
    /*
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            fetchedResultsController?.delegate = self /* MapViewController.swift
             must ADD Part 6 for error to go away - assign “NSFetchedResultsControllerDelegate” to SELF (=“CoreDataTableViewController”). with extension CoreDataTableViewController: NSFetchedResultsControllerDelegate { - or else - error throws as u can’t assign a UITableVC to a type = NSFetchedResultsControllerDelegate
 */
            
            executeSearch()
            
            // how to call map to reload ??? check On the Map's code.
            // is it like - grab all the annotaions from the map, and then remove them all , and then (It's NEW) load the pin that is from core DATA
            // tableView.reloadData()
        }
    } */
    
    // delete part 1 as no use - instead , do below:
    //1. create NSFetchRequest for Pin entity
    //2. Use context to fetch the data using NSFetchRequest
    
    //stack.context.fetch .
    
    /*
     func fetchAndPrintEachPerson() {
     let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
     do {
    
         let fetchedResults = try managedObjectContext!.fetch(fetchRequest)
         // type case fetchedResults to [Pin]
         // fetchedResults  is array of Pin
         // pin.lat,
         for item in fetchedResults {
         print(item.value(forKey: "name")!)
         }
         
     } catch let error as NSError {
         // something went wrong, print the error.
         print(error.description)
         }
     }
 */
    // MARK: To Fetch Entity Pin's from NSManagedObjectContext's (save as "context) func "fetch"
    func fetchAllPins() -> [Pin]? {  //  is this correct type of return? [Pin] - is class Pin
        //1. create NSFetchRequest for Pin entity
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin") // <Pin> -> "public class Pin: NSManagedObject" - and since .fetch(expecting: NSFetchRequest  type, so we set fetchRequest = NSFetchRequest<Pin>
        
        do {
            //2. Use context to fetch the data using NSFetchRequest - //stack.context.fetch .
            // we set let stack = CoreDataStack.sharedInstance() -> inside CoreDataStack is let context: NSManagedObjectContext -> so we call stack.context.fetch -> and inside "context" (=open class NSManagedObjectContext ) -> it has func "fetch" -> so, context.fetch
            // template: let fetchedResults = try managedObjectContext!.fetch(fetchRequest)
            let fetchedResults = try stack.context.fetch(fetchRequest) as [Pin] // right side returns [Pin]
            print("AllPins are... \(fetchedResults.count), \(fetchedResults) ")
            return fetchedResults
            
        } catch let error as NSError {
            // something went wrong, print the error.
            print("error from func fetchAllPins() is \(error)")
        }
        return nil // it returns optional Pin - we need to return something in do/catch loop, so we set the [Pin]? as an optional
    } // end of func fetchEachPin() {
    

    /*
    // Part 2 - MARK - Initializers
    init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>) {
        fetchedResultsController = fc
    }
    */
    
    // MARK: - MKMapViewDelegate - Calling its func here ...
    
    // Design the "pin" - appearance/ property - ASK MENTOR WHAT IT IS....
    
    // Like each row indexPath, add the next content. Similar here each spot, add the next annotation
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath method in TableViewDataSource.
    
    // Under MKMapViewDelegate - public protocol MKMapViewDelegate : NSObjectProtocol {
    //  optional public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?

    // MENTOR's advise: this func is automatically called by SYSTEM when a user drops a new pin and user move to another location - at the system level -> it keeps checking any NEW annotation added / or user change the location in the map even though the pin is already there (in case they drag it) -> then it will do if/ else statement below.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        print("func mapView is being called") // educational purpose!
        let reuserId = "pin"
        //    From MKMapViewDelegate - public protocol MKMapViewDelegate : NSObjectProtocol { it has:
        //  open func dequeueReusableAnnotationView(withIdentifier identifier: String) -> MKAnnotationView?
        // pinView here = cell in collection/ table view - to dequeueReusable views...
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuserId) as? MKPinAnnotationView
        
        // pinView is now one of the "MKPinAnnotationView" -> means it can call its properties as below:
        if pinView == nil {   // if there is no pin ever assigned on the map YET, set its design
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuserId)
            pinView!.pinTintColor = .red
            
            pinView!.isDraggable = true
            pinView!.animatesDrop = true
            
            
            print("if pinView == nil")
        } else {  // dequeueReusable "Cell" = place pin of student on the map
            pinView!.annotation = annotation
            print("if pinView != nil")
        }
        return pinView // display pin on the map ...?? - YES!
    }
    
    
    
    
    /* MARK - When app launched, map is loaded. Region changes regardless. We don't want to record it. The ONLY thing we want to record is the REAL value from user's interaction. */
    func regionDidChangeFromUserInteraction() -> Bool {
        let view = mapView.subviews[0]
        // register gestureRecognizer - if .began, means real user's interaction
        if let gestureRecognizers = view.gestureRecognizers { // an array
            
            for recognizer in gestureRecognizers {
                if (recognizer.state == UIGestureRecognizerState.began || recognizer.state == UIGestureRecognizerState.ended) {
                    return true
                }
            } // End of for recognizer
            
        } // End of if let statement
        return false
    }
    
    /*
    /* MARK - Add regionWillChangeAnimated to enable dragging PIN */
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        if regionDidChangeFromUserInteraction() {
            
            // MARK - Code to change the lat and lon!
            // code here...
            
            
            
        }
        
        
    } // END of func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
 */
    
    /* MARK - change (VAR) properties of zoom level - use mapviewdelegate func ->
     detecting pinching motion - when REGION of the map is changed. */
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // from UI - mapView -> GET the NEW value FOR key array "savedMapRegion"
        
        // Only if region change is caused by user's interaction.
        if regionDidChangeFromUserInteraction() {
            
            // MARK - Code to change the lat and lon!
            // code here...
            
            
            let regionToSave = [
                // lat/ lon
                "mapRegionLat": mapView.region.center.latitude,
                "mapRegionLon": mapView.region.center.longitude,
                
                // span
                "latDelta": mapView.region.span.latitudeDelta,
                "lonDelta": mapView.region.span.longitudeDelta
            ]
            
            UserDefaults.standard.set(regionToSave, forKey: "savedMapRegion")
            /* this func should not be called UNLESS user change the region - BUT looks like when app first launch - the map is loaded -> that somehow triggers CHANGE in region. -> we can fix it by writing another func to ensure this func is ONLY called when a user did move the map and triggers CHANGE in region! */
            print("Region is changed due to user's interaction, new value updated to \(UserDefaults.standard.object(forKey: "savedMapRegion"))")
        }
    } // END of func mapView - regionDidChangeAnimated
    
    
    // MARK - get Current tapped/ selected Pin on the map
    
    
    
    
    // Overall - declare @ beginning of the file, MKMapViewDelegate -> use didSelect to get what pin is selected -> set NSPredicate as a condition to find this selected pin -> init fetchRequest for Pin and add pred to this fetchRequest -> this finds this selected pin through the Core Data Model object -> and return a fetchResult -> if found -> return a Pin Object
    
    // Step 1 - MKPointAnnotation -> Latitude and longitude -> NSPredicate -> Pin -> PhotoAlbumViewController
    // use MKMapViewDelegate's didselect function to get the chosen pin's Lat/ Lon -> use NSPredicate to check if this pin is in the Core Data. And pass Pin object to PhotoViewController
    
    // MARK - Enable mapView's clickability
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        let a
//        
//    }
    
    
    
    // Currently, pins are shown on map, but not able to be tapped
    // OS level detect when a pin is selected, trigger below func
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        // when user taps on this pin, what do you want it to respond...
        // pass Coordinate to FetchRequest's predicate condition -> find matching pin from CoreData -> save as currentPin -> pass it to PhotoVC with prepare Segue & perform Segue
        
        print("User selected a Pin, \(view.annotation?.coordinate)")
        
        // get selected pin's coordindate
        if let selectedCoordinate = view.annotation?.coordinate {
            
            // also need to be round, when fetching
            // Write the predicate for Double for CoreData entity - value: %lf - long float
            // Pass lat/ lon at decimal 5.
            let pred = NSPredicate(format: "latitude == %lf AND longitude == %lf", ((selectedCoordinate.latitude*100000).rounded()/100000), ((selectedCoordinate.longitude*100000).rounded()/100000)) // "=" is same as "==" in predicate - both mean equal to
            
            print("setting condition below to look up from coreData...")
            print("lat after round up is \((selectedCoordinate.latitude*100000).rounded()/100000)")
            
            print("lon after round up is \((selectedCoordinate.longitude*100000).rounded()/100000)")
            
            // pred is a condition - use this NSPredicate, we need to create a fetchResult
            // fetchRequest has a predicate property, so we add that property now
            
            // will return the PIN object
        
            //1. create NSFetchRequest for Pin entity- similar to "which entiry data are you looking into?
            let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin") // <Pin> -> "public class Pin: NSManagedObject" - and since .fetch(expecting: NSFetchRequest  type, so we set fetchRequest = NSFetchRequest<Pin>
            do {
                // Look through Pin Object against those in Core Data for a match?
                // Find a PIN match in CoreData (it should because Pin Instance is created already) -> return its object...
                fetchRequest.predicate = pred // condition
                
                //2. Use context to fetch the data using NSFetchRequest - //stack.context.fetch .
                // we set let stack = CoreDataStack.sharedInstance() -> inside CoreDataStack is let context: NSManagedObjectContext -> so we call stack.context.fetch -> and inside "context" (=open class NSManagedObjectContext ) -> it has func "fetch" -> so, context.fetch
                // template: let fetchedResults = try managedObjectContext!.fetch(fetchRequest)
                let fetchedResults = try stack.context.fetch(fetchRequest) as [Pin] // right side returns array [Pin], since there is only one pin should be found, grab the pos[0]
                print("fetchedResults is \(fetchedResults)")
                self.currentPinObject = fetchedResults[0]
                /* testing (37.2542, 122.0396)  (Hakone garden)
                currentPinObject?.latitude = 37.2542
                currentPinObject?.longitude = 122.0396 */
                
                print("matching Pin found from Core Data is, \(self.currentPinObject), latitude is \(self.currentPinObject?.latitude), longitude is \(self.currentPinObject?.longitude)")
                
                searchByCoordinate() // call API - request Flickr server based on currentPin's lat, lon to return corresponding Photo back and save to our coreData
                
            } catch let error as NSError {
                print("error from currentPin is \(error)")
            }
            
            // this func will trigger prepare segue that pass this currentPinObject to PhotoAlbumViewController
            self.performSegue(withIdentifier: "PhotoAlbumVC", sender: self)
            
        } // END of if let selectedCoordinate
    } // END of func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    
    // first, write prepareForSegue > second, write performSegue - Then, when .performSegue is called, it triggers this func.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let nextController = segue.destination as! PhotoAlbumViewController
        nextController.currentPinObject = self.currentPinObject
        
    }
    
    
    
    
    
    // Step 2.1 - pass Pin object and Stack from mapvc -> photalbumvc -> flickrconveneince.
    // Step 2.2 - perform segue under didSelect func - performSegue(withIdentifier: "PhotoAlbumVC", sender: self)
    

    
    
    
    
}

extension MapViewController {
    
    func displayAllAnnotationsFromCoreData() -> Void {
        
        // Get mapView all annotations & remove them all from previous
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        // MARK - fetch from coredata what user has dropped (get the pin info) -> and add it to the mapview after user returns to the app.
        
        let allPins = fetchAllPins() as [Pin]! // this returns all pins saved to entity Pin... I want to retrieve all pins and then drop pin added to the map
        
        // add "if let" OR add "!" after [Pin] (ask MENTOR ???) to UNWRAP the optional pin value! - because returns type from fetchAllPins is - [Pin]? -> "?" = optional -
        
        var annotations = [MKPointAnnotation]() // create an array to store all pins' coordinate
        
        // use for loop to keep adding each annotation to mapView ?!
        // class Pin has latitude & longitude
        
        for pin in allPins! {
            let long = pin.longitude as Double
            let lat = pin.latitude as Double
            
            let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            // convert latitude / longitude to MKPointAnnotation()   -> we need to do CLLocationCoordinate2D(latitude: lat, longitude: long
            annotation.coordinate = coordinates
            annotations.append(annotation)
        }
        print("total annotations are \(annotations.count)")
       
        self.mapView.addAnnotations(annotations)
        print("mapView.annotations.count \(self.mapView.annotations.count)")
        self.mapView.showAnnotations(annotations, animated: false)

       // mapView.addAnnotations(annotations) // most efficient way to add pins/ annotations on map - one time
        
        
    } // END of func displayAllAnnotationsFromCoreData()

    func handleLongPress(_ gestureRecognizer : UIGestureRecognizer) {
        if gestureRecognizer.state != .began {return} /* The gesture when the tap has been pressed for the specified period (minimumPressDuration)*/
        let touchPoint = gestureRecognizer.location(in: mapView) // Get location from added pin
        // let touchMapCoordinate = mapView.convert(CGPoint, toCoordinateFrom: <#T##UIView?#>) // CLLocationCoordinate2D method - CGPoint = CoreGraphic Point from another deeper API
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        // "touchMapCoordinate" is type of CLLocationCoordinate2D -> init(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
        self.lat = touchMapCoordinate.latitude
        self.lon = touchMapCoordinate.longitude
        
        print("touchMapCoordinate is ... \(touchMapCoordinate)") // expected print out: (latitude, longitude)
        
        // MARK - trigger func to pass lon/ lat to CREATE INSTANCE of a PIN - also, call ".save" to save this PIN instance to CORE DATA !
        // createPinInstance((self.lat), (self.lon))
        // only SAVED up to 5 decicmal of lon/ lat
        createPinInstance(((self.lat*100000).rounded()/100000), ((self.lon*100000).rounded()/100000))
        
        let annotation = MKPointAnnotation() // Pin
        annotation.coordinate = touchMapCoordinate
        
        /* MARK - we don't need to append the annotation (Pin) to a variable - Instead, we need to add it to COREDATA
        create NSManagedObject pin -> and save it to database to coreData
        annotations.append(annotation) // so when to call this func - Ans: when minimumPressDuration = 1.0 */

        // MARK - add a new  of MKPointAnnotation (a PIN) to mapView to display
        mapView.addAnnotation(annotation)
    }
    
    
    // FOR TESTING ONLY
    private func bboxString(_ latitude: Double, _ longitude: Double) -> String {
        
        // ASK MENTOR ?? do i still need to check if self.lon has something? but with i wrote if let latitude = self.lat -> it raised error...
        
        // ensure bbox is bounded by min and max
        let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    func searchByCoordinate() {
        // call Flickr API here
        /* this block to test getTotalPages before get getPhotoArrayByRandPage

        // *** currentPinObject must has value as calling this after it's set inside didSelect
        if let latitude = currentPinObject?.latitude, let longitude = currentPinObject?.longitude {
            let methodPara = [
                Constants.FlickrParameterKeys.Method : Constants.FlickrParameterValues.SearchMethod,
                Constants.FlickrParameterKeys.APIKey : Constants.FlickrParameterValues.APIKey,
                Constants.FlickrParameterKeys.BoundingBox : bboxString(latitude, longitude),
                Constants.FlickrParameterKeys.SafeSearch : Constants.FlickrParameterValues.UseSafeSearch,
                Constants.FlickrParameterKeys.Extras : Constants.FlickrParameterValues.MediumURL,
                Constants.FlickrParameterKeys.Format : Constants.FlickrParameterValues.ResponseFormat,
                Constants.FlickrParameterKeys.NoJsonCallback : Constants.FlickrParameterValues.DisableJSONCallback,
                ]
        
        FlickrConvenience.sharedInstance().getPhotoTotalPage(methodPara as [String : AnyObject]) { (totalPages, error) in
                print("totalPages is \(totalPages)")
            } 
         */
        
        // currentPinObject must has value as calling this after it's set inside didSelect
        
        
        
        if let currentPin = self.currentPinObject {
            FlickrConvenience.sharedInstance().getPhotoArrayByRandPage(currentPin) { (PhotoArray, error) in
                
                if let photoArray = PhotoArray {
                    
                    print("Photo array length is \(PhotoArray?.count)")
                    
                    // for loop , for each photo array, grab each media_url, title.
                    for photo in photoArray {
                        
                        // call  createPhotoInstance inside loop
                        let mediaURL = photo["url_m"] as! String
                        let photoName = photo["title"] as! String
                        
                        DispatchQueue.main.async {
                            Photo.createPhotoInstance(mediaURL, photoName, currentPin, self.stack.context)
                            
                            // there is no "save" function to be called YET - add it with do/ try/ catch block - to avoid FAILURE
                            do {
                                try self.stack.saveContext()
                                print("Successfully saved")
                            } catch {
                                print("Saved failed")
                            }
                        } // END of DispatchQueue.main.async
                    } // END of for loop
                }
            }
        } // end of if let
 
      } // end of searchByCoordinate
        
//        } // end of if let latitude
        
//        
//        FlickrConvenience.sharedInstance().getPhotoArrayByRandPage(currentPinObject!) { (photoArray, error) in
//            // unwrap currentPin
//            
//            // photoArray comes back... we will call craetePhotoInstance and save to core data one by one....
//            
//            
//            
//            
//            
//        } // end of FlickrConvenience.sharedInstance().getPhotoArrayByRandPag
        
        
    
    
    // CREATE a Pin Instance
    private func createPinInstance(_ lat: Double, _ lon: Double) -> Void {
        print("in func createPinInstance")
        print("lat is \(lat), lon is \(lon)")
        // Create a PIN instance
        // convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) { from class PIN
        let newPin = Pin(latitude: lat, longitude: lon, context: stack.context)
        print("newPin is \(newPin)")
        
        // call a func to call Flickr API to grab Photos associated with this new PIN..
        
       
        // there is no "save" function to be called YET - add it with do/ try/ catch block - to avoid FAILURE
        do {
            try stack.saveContext()
            print("Successfully saved")
        } catch {
            print("Saved failed")
        }
 
 
        // if need to save i/s autosave, here is the place to call save() -> Ans: Mentor- autosave only neeed when app is handling large data continously.
    } // END of private func createPinInstance
    
    // MARK: - MapViewController - Configure UI
    // pass error to this func - either it's self made up or error passed from the server through .dataTask ???
    
    // nikki - app specific - display label "No photo returned" when no photo is returned - don't use Alert Box!!
    func displayError(_ errorString: String?) {
        if let errorString = errorString { // unwrap the value of errorString
            
            // set UI alertVC
            let errorAlert = UIAlertController(title: "Failure", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                // what happens when user clicks ok? Ans: to dismiss the alert box
                errorAlert.dismiss(animated: true, completion: nil)
            }))
            
            // need to call alert to present @ main queue
            performUIUpdatesOnMan {
                self.present(errorAlert, animated: true, completion: nil) //  have to place any interface code on mainQueue
            }
        } //END of if let errorString
    } // END of func displayError
} // END of extension MapViewController {

/* Here we create an enum with associated values and constrained to a generic type, you probably heard about generics in Swift, but what are they? Generic programming is a way to write functions and data types while making minimal assumptions about the type of data being used, Swift generics create code that does not get specific about underlying data types, allowing for elegant abstractions that produce cleaner code with fewer bugs! 
    The benefit of use generics in your programming is that you won’t have to repeat implementations separately for each specific type; this enum, for example, will accept any type and in the success case, will associate that type to its associated value type.*/
enum Result <T>{
    case Success(T)
    case Error(String)
}


// to do:
// photos -> 
// Create ONE view controller -> contains: 2/3 collection view and 1/3 a map view
// data in collection view controller -> array -> fetch from CoreData and load on collection view controller?

// store below in a function:
// flicker API -> map to the photos (check Flickr's app)
// photos -> stored using Core data  ------> two steps name and url (there is no binary data)
// collection view reload
// cellforItem at indexpath -> take each URL , -> calling data for session (HTTP get function) with image URL ->download the binary data for photo image
// show binary data in photo image (create UI image from binary data)
// - end-



//30%
// collection view -> view did load 
// call the flicker API -> meta data -> image URL and title... (there is no binary data)
// create entity for Photos before storing
// photos -> stored using Core data  ------> two steps name and url (there is no binary data)
//30%
// name, url -> calling data for session (HTTP get function) with image URL ->download the binary data for photo image
// show binary data in photo image (create UI image from binary data)

// reload collection view
// 40%
// refresh collection view/ add collection view
// delete all data, and call func of calling flicker API, reload data, refresh data
























