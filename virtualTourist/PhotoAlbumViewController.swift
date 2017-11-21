//
//  PhotoAlbumViewController.swift
//  virtualTourist
//
//  Created by Nikki L on 11/12/17.
//  Copyright © 2017 Nikki. All rights reserved.
//

import UIKit

class PhotoAlbumViewController: UIViewController {
    @IBOutlet weak var noPhotoLabel: UILabel!
    @IBOutlet weak var newCollection: UIButton!
    @IBAction func newCollection(_ sender: Any) {
        // not resetting TotalPage but calling func "getPhotoArrayFromFlickrWithRandomPage"
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUIEnabled(false)
        
    }

    // need to handle error passed back ...
    // when error is passed to ViewController, do below..
    // call displayError() -> expects String -> it shows alert box with string
    // instead of calling ViewController's func displayError, we pass the "error" to completion handler!
    // self.displayError("There was an error with your request \(error?.localizedDescription)") // convert NSError to String with ".localizedDescription"

}


private extension PhotoAlbumViewController {
     // MARK - call these func here on PhotoAlbumViewController.swift
    // nikki's // call below API starts calling Flickr server and update it to false by hideAI(false) when photos returned
    // Configure hidding the activity indicator - for each picture placeholder! do it later Nikki
    func hideAI(_ enabled: Bool) -> Void {
        
    }
    
    // disable "New Collection"
    func setUIEnabled(_ enabled: Bool) {
        newCollection.isEnabled = enabled  // 1. to disable newCollection button, need to pass "false", 2. enable new collection when API is done calling. - need to work on nikki
    }
    
    // Set a function here - TO show label if TotalPage == 0
    // func
    
    
    
    

}
