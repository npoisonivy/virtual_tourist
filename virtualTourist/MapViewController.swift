//
//  MapViewController.swift
//  virtualTourist
//
//  Created by Nikki L on 7/14/17.
//  Copyright © 2017 Nikki. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView! // it does not have MKMapViewDelegate till adding "self.mapView.delegate = self  // self = MapVC.swift"
    
    var annotations = [MKPointAnnotation]() // store all annotations/ pin locations from the mapView
    var lat: Double = 0.0
    var lon: Double = 0.0
    
    let stack = CoreDataStack(modelName: "Model")!
    
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
            // we set let stack = CoreDataStack -> inside CoreDataStack is let context: NSManagedObjectContext -> so we call stack.context.fetch -> and inside "context" (=open class NSManagedObjectContext ) -> it has func "fetch" -> so, context.fetch
            // template: let fetchedResults = try managedObjectContext!.fetch(fetchRequest)
            let fetchedResults = try stack.context.fetch(fetchRequest) as [Pin] // right side returns [Pin]
            print(fetchedResults)
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.mapView.delegate = self // self = MapViewController.swift -> since MapVC has "MKMapViewDelegate" -> self can call mapview's delegate func, now, assign property "mapView" this ability too (tableview has built-in, no need to do this part)

        // Mentor advises me to read more about tap/ other geseture recognizzer!
        // MARK - Create UILongPressGestureRecognizer
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 1.0
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
        mapView.addAnnotations(annotations) // most efficient way to add pins/ annotations on map - one time

    }
    
  
    
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
            pinView!.canShowCallout = true // Callout = a callout bubble will be shown when pin
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
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
            } // End of for recogizer
            
        } // End of if let statement
        return false
    }
    
    // MARK - change (VAR) properties of zoom level - use mapviewdelegate func -> detecting pinching motion - when REGION of the map is changed.
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // from UI - mapView -> GET the NEW value FOR key array "savedMapRegion"
        
        // Only if region change is caused by user's interaction.
        if regionDidChangeFromUserInteraction() {
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
    }
}

extension MapViewController {
    func handleLongPress(_ gestureRecognizer : UIGestureRecognizer) {
        if gestureRecognizer.state != .began {return} /* The gesture when the tap has been pressed for the specified period (minimumPressDuration)*/
        let touchPoint = gestureRecognizer.location(in: mapView) // Get location from added pin
        // let touchMapCoordinate = mapView.convert(CGPoint, toCoordinateFrom: <#T##UIView?#>) // CLLocationCoordinate2D method - CGPoint = CoreGraphic Point from another deeper API
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        // "touchMapCoordinate" is type of CLLocationCoordinate2D -> init(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
        self.lat = touchMapCoordinate.latitude
        self.lon = touchMapCoordinate.longitude
        
        print("touchMapCoordinate is ... \(touchMapCoordinate)") // expected print out: (latitude, longitude)
        
        // call below at background -- UNCOMMENT THIS !!!
        // MARK - add func xxx here - to pass "touchMapCoordinate"'s Lat & Long to Flickr's getPhoto API call
        // searchByCoordinate(lon, lat)  // hardcode this searchByCoordinate(37.2542, 122.0396)  (Hakone garden)
        
        // MARK - trigger func to pass lon/ lat to CREATE INSTANCE of a PIN - also, call ".save" to save this PIN instance to CORE DATA !
        createPinInstance(self.lon, self.lat)
        
        let annotation = MKPointAnnotation() // Pin
        annotation.coordinate = touchMapCoordinate
        
        /* MARK - we don't need to append the annotation (Pin) to a variable - Instead, we need to add it to COREDATA
        create NSManagedObject pin -> and save it to database to coreData
        annotations.append(annotation) // so when to call this func - Ans: when minimumPressDuration = 1.0 */

        // MARK - add a new  of MKPointAnnotation (a PIN) to mapView to display
        mapView.addAnnotation(annotation)
        
    }
    
    
    func searchByCoordinate() {
        // call Flickr API here
        // bbox (lat, lon)
        // return photos' data -> only get the photo's TOTAL PAGES, and pass it to another API call for THAT PAGE's photo data
        
        // 1. set methodparameters - now, add related constants to FlickrParameterKeys under Constants.swift
        let methodParameters = [
            Constants.FlickrParameterKeys.Method : Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey : Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox : bboxString(),
            Constants.FlickrParameterKeys.SafeSearch : Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras : Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format : Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJsonCallback : Constants.FlickrParameterValues.DisableJSONCallback
        ]
        
        /* 2. Call a helper func "getPhotoTotalPageFromFlickrBySearch" that handles 
         A - network call to return Total Page Numbers
         B - the methodparameters to form something like this method=flickr.photos.search&api_key=3f8c7ede36 (add "=", "&" - to form a URL to input to step 3
         See below "2"
        */
        getPhotoTotalPageFromFlickrBySearch(methodParameters as [String: AnyObject])
        
    }
    
    private func bboxString() -> String {
        
        // ASK MENTOR ?? do i still need to check if self.lon has something? but with i wrote if let latitude = self.lat -> it raised error...
        
        // ensure bbox is bounded by min and max
        let minimumLon = max(self.lon - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(self.lat - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(self.lon + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(self.lat + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    // SHOULD MOVE ALL THESE NETWORK CALL AT ANOTHER FILE!
    // 2. This helper func to deal with step 2 above - to make a Networking call - to return Total Page No.
    private func getPhotoTotalPageFromFlickrBySearch(_ methodParameters: [String: AnyObject]) {
        
        // extract lon/ lat from self.lon/ self.lat
        
        // create session and request
        let session = URLSession.shared
        // 3. call a helper func to pass "url" as input to make the network call
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        
        // create network request - check Flickr's app for the codes
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            
            if error != nil { // returned error is an NSerror, displayError expects String...
                print(error)
                // call displayError() -> expects String -> it shows alert box with string
                self.displayError("There was an error with your request \(error?.localizedDescription)") // convert NSError to String with ".localizedDescription"
                return // ask mentor ??? why do I need "return" -> my guess: return is to dismiss the alert box after showing?
            } else { // no error
                // nikki
                
                // this block will call network call and return total Pages
                // grab how many photo pages there are - look at Flickr's project
                // call getPhotoTotalPageFromFlickrBySearch()
                // call getPhotoFromFlickrBySearchWithRandomPageNumber(methodParameters as [String: AnyObject], _ completionHandlerForgetPhotoFromRandomPage: @escaping (_ randomPageNo: ??) -> Void)
                
                // write a func getPhotoFromFlickrBySearchWithRandomPageNumber, inside it, call another network call - getPhotoTotalPageFromFlickrBySearch -> when this returns, I call "completionHandlerForgetPhotoFromRandomPage" and put the "random page" that is returned 
                
                // here this block, will also
                
                
                
                
                
                
                
                
                // call func getPhotoTotalPageFromFlickrBySearchByRandomPage(methodPara, RandomPage)
                // This block of code will run only when server returns TotalPagesNumber
                // deal with the totalPages here....
                
                // CALL func "getPhotoFromFlickrBySearchWithRandomPage" - input the random pages in.
                
                // below should call func to input random page and return pic from that random page - func "getPhotoFromFlickrBySearchWithRandomPageNumber"
                
                // after "total pages" is returned, pass total page to func getPhotoFromFlickrBySearchWithRandomPage
                //getPhotoFromFlickrBySearchWithRandomPage(randomPage)
                

                
            }

        
            }// end of if error
        } // end of let task =
    } // end of private func getPhoto....
    

    
    // MARK - call below func ONCE inside func "getPhotoTotalPageFromFlickrBySearch" & also when user tap "New Collection" - this func RETURNS ACTUAL PHOTO
    private func getPhotoFromFlickrBySearchWithRandomPageNumber(_ randomPage: Int){
        // pick a random page to query !
        // let pageLimit = min(total)
        
        // add Page to parameter...
        let methodParameters = [
            Constants.FlickrParameterKeys.Method : Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey : Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.SafeSearch : Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras : Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format : Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJsonCallback : Constants.FlickrParameterValues.DisableJSONCallback,
            // Constants.FlickrParameterKeys.Page = random page??
    
        ]

        
        
        // Make another network call, this time, search with the random number obtained from above
        
        
        
        // when random page pictures returned, save the Photo to CoreData - by creating Photo instance. Save Photo URL, title
        
        // 4. Photos data returned from step 3 - we need to save those photo to CoreData by creating NSManagedObject
    }
    
    // 3. Create a helper func make "url", so we can pass it to func "" inside the network call
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        /* Above already add .scheme/ .host/ .path these properties to components 
         to form -> https://api.flickr.com/services/rest/? */
        
        components.queryItems = [URLQueryItem]() // declare a property queryItems and create an array for it, so we can start adding DICT key:value to this array. This array datatype is URLQueryItem (= A single name-value pair)

        for (key, value) in parameters {
            // CONVERT parameter's dictionary to TYPE queryItem's dictionary
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            
            // APPEND EACH pair of queryItem's dictionary to array [components.queryItems]
            components.queryItems!.append(queryItem)
        }
        
        return components.url! // includes components's scheme, host, path, and dictionary from "parameters"
        
    }
    
    // CREATE a Pin Instance
    private func createPinInstance(_ lat: Double, _ lon: Double) -> Void {
        
        // Create a PIN instance
        // convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) { from class PIN
        let newPin = Pin(latitude: lat, longitude: lon, context: stack.context)
        print("newPin is \(newPin)")
        
        // call a func to call Flickr API to grab Photos associated with this new PIN..
        
        
        
        
        
        // there is no "save" function to be called YET - add it with do/ try/ catch block - to avoid FAILURE
        do {
            try stack.saveContext()
            self.fetchAllPins()
            print("Successfully saved")
        } catch {
            print("Saved failed")
        }
 
        print("newPin is, \(newPin)")
 
        // if need to save i/s autosave, here is the place to call save() -> Ans: Mentor- autosave only neeed when app is handling large data continously.
    }
    
    // A Flickr API call to return Photos based on lat/ lon passed, when a new PIN is created.
    
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

// MARK: - MapViewController - Configure UI
private extension MapViewController {
    
    // pass error to this func - either it's self made up or error passed from the server through .dataTask
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
    
    // nikki's // call below API starts calling Flickr server and update it to false by hideAI(false) when photos returned
    // Configure hidding the activity indicator
    func hideAI(_ enabled: Bool) -> Void {
        
    }
    
} // END of private extension MapViewController




