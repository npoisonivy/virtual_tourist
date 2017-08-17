//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true


// Get Student Locations - do u need to specify max 100 students' data to be retrieved ?
//func getStudentLocations(_ completionHandlerForStudentLocations: @escaping (_ results: [Students]?, _ error: NSError?)-> Void) {
//    let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!) // make sure to get only the last (most recent) 100 students. - do i need to add "skip" ???
//    request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
//    request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
//    let session = URLSession.shared
//    let task = session.dataTask(with: request as URLRequest) { data, response, error in
//        if error != nil { // Handle error...
//            return
//        }
//        print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
//    }
//    task.resume()

//}
//


//let session = URLSession.shared
//let task = session.dataTask(with: request as URLRequest) { data, response, error in
//    if error != nil { // Handle error...
//        return
//    }
//    print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
//}
//task.resume()

//let urlString = "http://quotes.rest/qod.json?category=inspire"
//let url = URL(string: urlString)
//let request = NSMutableURLRequest(url: url!)
//let session = URLSession.shared
//let task = session.dataTask(with: request as URLRequest) { data, response, error in
//    if error != nil { // Handle error
//        return
//    }
//    print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
//}
//task.resume()

