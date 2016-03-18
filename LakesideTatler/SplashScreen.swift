//
//  SplashScreen.swift
//  HaleSentinel
//
//  Created by Jacob Kohn on 2/10/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit
import wpxmlrpc
import CoreData

class SplashScreen: UIViewController {
    
    var articles = [NSDictionary]()
    var timesLoggedIn = [NSManagedObject]()
    var lastLogIn = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName:"LogIn")
        let error: NSError?
        var fetchedResults = [NSManagedObject]()
        do {
            fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        timesLoggedIn = fetchedResults
        
        testUsers()
        
        if(timesLoggedIn.isEmpty) {
            lastLogIn = NSDate().timeIntervalSince1970 - 100000000.0
        } else {
            lastLogIn = Double(timesLoggedIn[timesLoggedIn.count - 1].valueForKey("time") as! Int)
        }
    
        loadArticles()
        
    }
    
    func testUsers() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName:"User")
        let error: NSError?
        var fetchedResults = [NSManagedObject]()
        do {
            fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        let users = fetchedResults
        
        print(users.count)
        
        for(var i=0; i<users.count; i++) {
            print((String(users[i].valueForKey("id") as! Int)) + ": " + (users[i].valueForKey("name") as! String))
        }
    }
    
    func loadArticles() {
        if(Reachability.isConnectedToNetwork()) {
            getArticles()
        } else {
            let alert = UIAlertController(title: "Oops!", message: "You are not connected to the Internet", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { (action) -> Void in
                self.loadArticles()
            }))
            
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }
    
    func getArticles() {
        var url = NSURL()
        url = NSURL(string: "http://tatler.lakesideschool.org/xmlrpc.php")!
        
        var request = NSMutableURLRequest()
        request = NSMutableURLRequest(URL: url)
        
        var session = NSURLSession.sharedSession()
        
        let filter : [String:AnyObject] = [
            "number" : 100,
            "post_status" : "publish",
            "orderby" : "id",
            "order" : "DESC"
        ]
        
        let encoder = WPXMLRPCEncoder(method: "wp.getPosts", andParameters: [0,"jacobk", "14050 1st Ave NE", filter])
        
        do {
            request.HTTPBody = try encoder.dataEncoded()
            request.HTTPMethod = "POST"
        } catch _ {
            print("oops")
        }
        
        var task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            if error != nil {
                print("callback fail")
                print(error)
            } else {
                
                let decoder = WPXMLRPCDecoder(data: data)
                
                if(decoder.isFault()) {
                    print("oopsies")
                } else {
                    
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                print("recieved")
                
                let decoder = WPXMLRPCDecoder(data: data)
                
                self.parseDecoder(decoder.object() as! [NSDictionary])
            })
        }
        task.resume()
    }
    
    func parseDecoder(decoder: [NSDictionary]) {
        
        // GET FIELDS
        
        var temp = [NSDictionary]()
        for(var i=0; i<decoder.count; i++) {
            let name = decoder[i]["post_title"] as! String
            var content = decoder[i]["post_content"] as! String
            let id = decoder[i]["post_id"] as! String
            let author = decoder[i]["post_author"] as! String
            
            var catagories = [String]()
            if(decoder[i]["terms"]!.count != 0) {
                for(var l=0; l<decoder[i]["terms"]!.count; l++) {
                    catagories.append(decoder[i]["terms"]![l]!["slug"] as! String)
                }
            }
            let status = decoder[i]["post_status"] as! String
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
            //dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
            let date = dateFormatter.stringFromDate(decoder[i]["post_date"] as! NSDate)
            
            var imageLink = String()
            var image = Bool()
            if let val = decoder[i]["post_thumbnail"]!["link"] {
                if let x = val {
                    imageLink = x as! String
                    image = true
                } else {
                    image = false
                    imageLink = ""
                }
            } else {
                image = false
                imageLink = ""
            }
            
            
            // Parse Content
            if let range = content.rangeOfString("\n\n") {
                
                let intIndex: Int = content.startIndex.distanceTo(range.startIndex)
                let startIndex2 = content.startIndex.advancedBy(intIndex + 2)
                
                let substring = content.substringWithRange(Range<String.Index>(start: startIndex2, end: content.endIndex))
                content = substring
            }
            
            if let range = content.rangeOfString("[/caption]") {
                let intIndex: Int = content.startIndex.distanceTo(range.endIndex)
                let startIndex2 = content.startIndex.advancedBy(intIndex + 2)
                
                let substring = content.substringWithRange(Range<String.Index>(start: startIndex2, end: content.endIndex))
                content = substring
                
            }
            
            if let range = content.rangeOfString("p>\n") {
                let intIndex: Int = content.startIndex.distanceTo(range.endIndex)
                let startIndex2 = content.startIndex.advancedBy(intIndex - 1)
                
                let substring = content.substringWithRange(Range<String.Index>(start: startIndex2, end: content.endIndex))
                content = substring
            }
            
            content = content.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
            
            content = content.stringByReplacingOccurrencesOfString("&nbsp;", withString: "", options: .RegularExpressionSearch, range: nil)

            
            let pd = ["title": name, "content": content, "id": id, "author": author, "catagories": catagories, "status": status, "imageLink": imageLink, "image": image, "date": date]
            
            if(name != "" && content != "[supsystic-gallery id=1 position=center]") {
                temp.append(pd)
            }
        }
        articles = temp
        
        sortArticles()
        
        print(NSDate().timeIntervalSince1970 - lastLogIn)
        
        if((NSDate().timeIntervalSince1970 - lastLogIn) > 5184000.0) {
            performSegueWithIdentifier("logIn", sender: nil)
        } else {
            performSegueWithIdentifier("doneLoading", sender: nil)
        }
    }
    
    /*
    * Sorts the articles by post_id
    * This solves the issue of 60+ posts dated March 4th
    */
    func sortArticles() {
        var temp = articles
        var new = [NSDictionary]()
        for(var i=0; i<articles.count; i++) {
            var tempIdx = 0
            for(var l=0; l<temp.count; l++) {
                if(Int(temp[l]["id"] as! String)! > Int(temp[tempIdx]["id"] as! String)) {
                    tempIdx = l
                }
            }
            new.append(temp[tempIdx])
            temp.removeAtIndex(tempIdx)
        }
        articles = new
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "doneLoading") {
            let controller = segue.destinationViewController as! ContainerVC
            controller.articles = self.articles
            controller.getUserList = false
        }
        if(segue.identifier == "logIn") {
            let controller = segue.destinationViewController as! LogInViewController
            controller.articles = self.articles
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}