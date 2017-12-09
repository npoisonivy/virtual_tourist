import Foundation
import UIKit
import MapKit
import CoreData

/**
 * Two techniques used
 *
 * - Selecting and deselecting cells in a collection
 * - Using NSFetchedResultsController with a collection
 *
 */

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK - Variables
    var sharedContext = CoreDataStack.sharedInstance().context
    
    /* The selected indexes array keeps all of the indexPaths for cells that are "selected". The array is
     used inside cellForItemAtIndexPath to lower the alpha of selected cells. You can see how the array
     works by searching through the code for "selectedIndexes" */
    var selectedIndexes = [IndexPath]()
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    // To receive what being passed from mapVC
    var currentPinObject:Pin? //  Error raised if -> var currentPinObject = Pin- remember to unwrap it below
    
    let stack = CoreDataStack(modelName: "Model")!  // because class func createPhotoInstance(_ mediaURL: String, _ photoName: String, _ currentPin: Pin, _ context: NSManagedObjectContext) -> Void { - has context as input... pass "stack.context" in context>
    
    // MARK - Outlets
    @IBOutlet weak var noPhotoLabel: UILabel!  // hide it if PhotoArray > 0
    @IBOutlet weak var newCollection: UIButton!
    
    // DO i need to add collectionView ? - YES - as need to manuplicate size of each Photo cell shows on this collection view
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var mapView: MKMapView! // it does not have MKMapViewDelegate till adding "self.mapView.delegate = self  // self = MapVC.swift"
    
    @IBAction func newCollection(_ sender: Any) {
        // not resetting TotalPage but calling func "getPhotoArrayFromFlickrWithRandomPage"
        
    } // END of @IBAction func newCollection
    
    // MARK: - Instance Variables
    
    /* Set up fetchResultsController - need to specify what to look for - Photos ONLY belongs to currentPin..
    Need to use NSPredicate ? - YES */

    
    
    // assign the type of class to this var "fetchedResultsController" (=NSObject) with @interface NSFetchedResultsController<ResultType:id<NSFetchRequestResult>> : NSObject
    // use this to debugg - lazy var fetchResultController: NSFetchedResultsController<Photo> = {
    
    lazy var fetchedResultsController: NSFetchedResultsController<Pin> = { () -> NSFetchedResultsController<
        Pin> in  // what is lazy var??? Does NSFetchedResultsController have completion handler...???
        
        //        // need to unwrap "currentPinObject" value as it can be optional
        // if let currentPinObject = self.currentPinObject {

        // when CH comes back, return NSFetchedResultsController back here, and we can call NSFetchRequest on that entity
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin") // resultType: "Photo"
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)] // add property to it - by order of Photo's property - descending...

        // add filter "pred" - tell CoreData what to look for self.currentPinObject!
        fetchRequest.predicate = NSPredicate(format: "latitude == %lf AND longitude == %lf", self.currentPinObject!.latitude, (self.currentPinObject?.longitude)!) // filter photos that are from currentPin ONLY! - currentPinObject == <Pin: 0x600000485500> (entity: Pin; id: 0xd000000000180000 <x-coredata://69D0775E-3962-4DA6-9A8D-CFBC7C89DFBE/Pin/p6>

        print("currentPinObject is \(self.currentPinObject)")
        print("fetchRequest.predicate is \(fetchRequest.predicate)")

        // intialize this fetchedResultsController (=NSObject) with properties
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        // public init(fetchRequest: NSFetchRequest<ResultType>, managedObjectContext context: NSManagedObjectContext, sectionNameKeyPath: String?, cacheName name: String?)

        fetchedResultsController.delegate = self // assign PhotoAlbumViewController.swift as delegate of fetchedResultsController. so we can call all func of fetchedResultsController RIGHT HERE @ PhotoAlbumViewController.swift
        print("fetchedResultsController is \(fetchedResultsController)")
       

        // } // END of if let currentPinObject = self.currentPinObject {

        return fetchedResultsController

    }() // END of lazy var fetchedResultsController:
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // check PhotoArray.count??? by calling currentPin up, look it up against CoreData fetchedResult. return photoArray.count here... nikki
        
        // viewDidLoad() - when loading pic (completion handler from URLsession call), disable new collection during the time - just like the one in onthemap - the loading one.
        
        // get the currentPinObject's coordinate, and display 
        self.mapView.delegate = self //  set PhotoAlbumVC.swift as delegate of mapView, so we can call mapView's func right here in this file
        displayCurrentPinOnMap()

        
    } // END of override func viewWillAppear
    
    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        print("in viewDidLoad()")
        
        super.viewDidLoad()
        
        // Start the fetched results controller -
        /*  Executes the fetch request on the store to get objects.
         Returns YES if successful or NO (and an error) if a problem occurred.
         An error is returned if the fetch request specified doesn't include a sort descriptor that uses sectionNameKeyPath.
         After executing this method, the fetched objects can be accessed with the property 'fetchedObjects' */
 
        var error: NSError?
        do {
            try fetchedResultsController.performFetch() // get objects!
            print(".performFetch completed without error")
            print("fetchedResultsController is \(fetchedResultsController)")
            print("fetchedObjects are photos ... \(fetchedResultsController.fetchedObjects)") // what;s the use of "fetchedObjects"???
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("Error performing initial fetch: \(error)")
        }
        
        updateBottomButton()
        
    } // END of viewDidLoad()
    
    
    
        // call getPhotoTotalPage and see what it returns - oh, also need to hard cord Hakone Garden @ the API call to make sure there are pictures to return for testing
        /*let methodParameters = [
            Constants.FlickrParameterKeys.Method : Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey : Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.SafeSearch : Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras : Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format : Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJsonCallback : Constants.FlickrParameterValues.DisableJSONCallback,
            ] */

        /*
        FlickrConvenience.sharedInstance().getPhotoTotalPage (methodParameters as [String : AnyObject]) {(totalPages, error) in
        //   func getPhotoTotalPage(_ methodParameters: [String: AnyObject], _ completionHandlerForGetTotalPages: @escaping (_ totalPages: Int?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        // it will return the total page there, and I will grab it ...
            if let totalPages = totalPages {
                print(totalPages)
            } else {
                print("error is \(error)")
            }
        }*/
        
        
//        collection view
//        fetchreqesut -> get photo per pin - indexpath - = for loop
//        establish the urlsession -> get binary data from each media_url that u pull out from the DB
//        display in main queue - concurrecnytypemain queue
//        
//        backgroundqueue - no need to specify
        
        
        
        
        // call getPhotoArrayByRandPage to test it out first. After testing, move it to
        /* prolly don't even have to pass latitude/ longitude as currentPinObject is passed to another viewcontroller ???
        FlickrConvenience.sharedInstance().getPhotoArrayByRandPage(currentPinObject) { (photosArray, error) in
            // code here
            // ??? where to put this code??? - should call this @ collection view, because photosArray got pass to there??? - but that means saving mediaURL and title will be done on collection view..... is that what we want? dont' we prefer doing it here @ FlickrConvenience???
            /* Passing photosArray to CHForGetPhotoArray - and return back to the View controller, can display "No image" there if there is no photo returned */
            // when random page pictures returned, save the Photo to CoreData - by creating Photo instance. Save Photo URL, title
            // parse the data - that only contains 1 page's PhotoArray - if count > 1 photo
            if (photosArray?.count)! > 0 { // if photosArray has > 0 photo = have photo at all
                // add placeholder for how many pictures
                // we need - each Photo's Title & MediumURL right now
                for photoDict in photosArray! {
                    // save each to core data
                    // each photoDict has Title (=name), MediumURL (=mediaURL)
                    let mediaURL = photoDict[Constants.FlickrResponseKeys.MediumURL]
                    let photoName = photoDict[Constants.FlickrResponseKeys.Title]
                    
                    // photoName, mediaURL are the names in CoreData exactly - add them one by one
                    FlickrConvenience.sharedInstance().createPhotoInstance(mediaURL as! String, photoName as! String)  
                    
                } // END of for photoDict in photosArray
            } // END of if photosArray.count > 0 {
        } // END of FlickrConvenience.sharedInstance().getPhotoArrayByRandPage {
        */
    
    
    // need to handle error passed back ...
    // when error is passed to ViewController, do below..
    // call displayError() -> expects String -> it shows alert box with string
    // instead of calling ViewController's func displayError, we pass the "error" to completion handler!
    // self.displayError("There was an error with your request \(error?.localizedDescription)") // convert NSError to String with ".localizedDescription"
    
    // MARK - to display pin that user just selected
    func displayCurrentPinOnMap() -> Void {
        print("in displayCurrentPinOnMap()")
        let annotation = MKPointAnnotation() // Pin
        if let currentPin = self.currentPinObject { // unwrap optional value
            
            // set span and zoom level
            let center = CLLocationCoordinate2D(latitude: currentPin.latitude, longitude: currentPin.longitude)
            let span  = MKCoordinateSpan(latitudeDelta: 0.075, longitudeDelta: 0.075)
            
            // Setting mapView's center & span - does not set Annotation location at all!
            mapView.region = MKCoordinateRegion(center: center, span: span)
            
            // add coordinate to the Annotation
            annotation.coordinate = CLLocationCoordinate2D(latitude: currentPin.latitude, longitude: currentPin.longitude)
        } // END of if let currentPin = self.currentPinObject
        
        self.mapView.addAnnotation(annotation)
        print("this pin coordinate is \(annotation.coordinate)")

    } // END of func displayCurrentPinOnMap()
    
    
    // Layout the collection view -
    override func viewDidLayoutSubviews() {
        print("in viewDidLayoutSubviews()")
        super.viewDidLayoutSubviews()
        
        // Layout the collection view so that cells take up 1/3 of the width, with no space in-between
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout() // declare class
        // call class' func - leaves no spaces between cells
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let width = floor(self.collectionView.frame.size.width/3) // returns float
        layout.itemSize = CGSize(width: width, height: width) // forms a square
        collectionView.collectionViewLayout = layout
        
    } // END of override func viewDidLayoutSubviews() {
    
    // Mark - UICollectionView
    
    // Configure Cell - what to display? - get it from object returned to "fetchedResultsController" earlier@
    func configureCell(_ cell: PhotoCollectionViewCell, atIndexPath indexPath: IndexPath) {
        print("in configureCell")
        
        // try to get photo from the fetchedResultsController (that is a Pin)
        // it's gonna be a Pin!
        let photo = self.fetchedResultsController.object(at: indexPath)
        print(photo)
        // return Photo object at the indexPath - includes - mediaURl, photoName & imageData, etc - check imageData == nil?
        // unwrap optional... 1. if first time, it's nil, if second time != nil
        if let photoImageData = photo.imageData {
            // if != nil, then display
            let image = UIImage(data: photoImageData as Data)
            cell.photoImageView.image = image
        } else {
            // call URLSession to get the ImageData
            // getImageData() // need completion handler, get back the binary data back + display placeholder before data is back
            let imageURL = photo.mediaURL // Photo's url is string already - @NSManaged public var mediaURL: String?
            
            // API call
            print("getImageData API call should be triggered")
            FlickrConvenience.sharedInstance().getImageData(photo, imageURL!, completionHandlerForGetImageData: { (imageData, error) in // "imageData" as NSData
                
                if let error = error {
                    print("ImageData cannot be retrieved from Flickr server")
                } else { // error is nil
                    // unwrap photoImageData + updating UI...
                    if let photoImageData = imageData {
                        
                        // add value to Photo's property "imageData" (NSData)
                        photo.imageData = photoImageData
                        
                        // need to call .save on the current Context - to really save it to CoreData!
                        // Call it with do/ try/ catch block - to avoid FAILURE
                        do {
                            try self.stack.saveContext()
                            print("Successuly saved property imageData to Photo")
                        } catch {
                            print("Save failed for - property imageData to Photo ")
                        }
                        
                        // retrieve url from coreData again for the image...
                        let image = UIImage(data: photoImageData as Data)
                        
                        // avoid blocking UI
                        DispatchQueue.main.async {
                            cell.photoImageView.image = image
                        } // END of DispatchQueue.main.async {
                    } // END of if let photoImageData = imageData {
                } // END of if/ else block
            }) // END of FlickrConvenience.sharedInstance().getImageData(photo, ima
          
          
            
            
        } // END of if/else block of if let photoImageData
    } // END of func configureCell
    
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("in numberOfSectionsInCollectionView()")
        
        return self.fetchedResultsController.sections?.count ?? 0
        
    } // END of func numberOfSections
    
    // essential method to make PhotoAlbumViewController a UICollectionViewDataSource
    // The number of rows in section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("in numberOfItemsInSectionInCollectionView()")
        
        let sectionInfo = self.fetchedResultsController.sections![section]
        
        print("number of Cells: \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
        
    } // END of numberOfItemsInSection
    
    // essential method to make PhotoAlbumViewController a UICollectionViewDataSource
    // A configured cell object - display Photo
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print("In collectionView - cellForItemAt IndexPath")
        // where you get the Photo image data from core data - indexPath is for loop already
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        configureCell(cell, atIndexPath: indexPath) // where it check if PhotoImage is nil or not, and set cell's image value
        
        return cell
        
    }
    
    // how does it change anything??? if we configureCell(cell, atIndexPath: indexPath) -> but not reading selectedIndexes???
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("in collectionView - didSelectItemAt indexPath")
        
        // grab the current cell
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        
        // Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
        // Nikki: xx.index(of: indexPath) Returns the first index where the specified value appears in the collection.
        // add indexPath to [selectedIndexes] IF indexPath not found (means first time user taps on the photo)
        // remove indexPath from [selectedIndexes] IF indexPath is FOUND (means user tapped on this photo before, 
        // and now DESELECT the photo!

        if let index = selectedIndexes.index(of: indexPath) {
            
            selectedIndexes.remove(at: index) // expects "Int"
            
        } else {
            selectedIndexes.append(indexPath)
            
        } // END of if/ else block of let index = selectedIndexes.index(of: indexPath)
        
        // Then reconfigure the cell - what happen if we don;t call this???
        configureCell(cell, atIndexPath: indexPath)
        
        // need to update the label? Yes - switch between "Remove Selected Photos" VS "New Collection" (= deleted ALL)
        updateBottomButton()
        
        
    }
    
    // MARK: - Fetched Results Controller Delegate
    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create
    // three fresh arrays to record the index paths that will be changed.
    // Nikki : Reset Array
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        // We are about to handle some new changes. Start out with empty arrays for each change type
        // Nikki: reset each array when CoreData changes! - to keep things updated!
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
        
        print("in controllerWillChangeContent")
    }
    
    // The second method may be called multiple times, once for each Photo object that is added, deleted, or changed.
    // System detect CoreData content changes, then triggers this func!
    // We store the index paths into the three arrays.
    // Nikki : amend 3 arrays according to status change of OBJECT (insert/ update/ delete)!
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type { // type - NSFetchedResultsChangeType - built-in
            
        case .insert:
            print("Insert an item")
            // Here we are noting that a new Photo instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
            
        case .delete:
            print("Delete an item")
            // Here we are noting that a Photo instance has been deleted from Core Data. We remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
            
        case .update:
            print("Update an item")
            // We don't expect Photo instances to change after they are created. But Core Data would
            // notify us of changes if any occured. This can be useful if you want to respond to changes
            // that come about after data is downloaded. For example, when an image is downloaded from
            // Flickr in the Virtual Tourist app - so you can detect new photos downloaded and add those photo to an array
            // so you can show new photos to users!
            updatedIndexPaths.append(indexPath!)
            break
            
        case .move:
            print("Move an item. We don't expect to see this in this app") // so do NOTHING
            break
        }
    }
    
    // This method is invoked after all of the changed objects in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). We now need to loop through the
    // arrays and perform the changes.
    //
    // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
    // Notice that all of the changes are performed inside a closure that is handed to the collection view.

    // Nikki : this func is evoked AFTER all 3 arrays are DONE updating. method "performBatchUpdates" only needed in CollectionView
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
        
        // when detects changes has made to CoreData -> we change our indexPaths arrays at the previous func,
        // NOW here, we display cell with updated arrays
        
        collectionView.performBatchUpdates({() -> Void in // completionHandler, so it does not block queue!
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath]) // need [] outside indepath - indicate its type is [Array.Index]
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
    
} // END of class PhotoAlbumViewController: UIViewController {

private extension PhotoAlbumViewController {
     // MARK - call these func here on PhotoAlbumViewController.swift
    // nikki's // call below API starts calling Flickr server and update it to false by hideAI(false) when photos returned
    // Configure hidding the activity indicator - for each picture placeholder! do it later Nikki
    func hideAI(_ enabled: Bool) -> Void {
        
    }
    
    // MARK - UI features
    func setUIEnabled(_ enabled: Bool) {
        noPhotoLabel.isHidden = enabled
        newCollection.isEnabled = enabled
        /* 1. @ viewDidLoad - if Photo.count == 0 -> setUIEnabled(false, false)
           2. @viewDidLoad - if Photo.count > 0 -> setUIEnabled(true, true) */
    }
    
    // MARK - Set it first @ viewDidLoad(), and then other places.
    // Change Button's label - between - "New Collection" VS "Remove Selected Photos"
    func updateBottomButton() {
        
        // if user selects >0 pic, then "Remove Selected"
        if selectedIndexes.count > 0 {
            newCollection.setTitle("Remove Selected Photos", for: .normal)
            
        } else { // else [selectedIndexes] is empty -> means nothing is selected -> then show "New Collection"
            newCollection.setTitle("New Collection", for: .normal)
        
        }
    } // END of func updateBottomButton() {
    
    
    
    
    
} // END of private extension PhotoAlbumViewController {
