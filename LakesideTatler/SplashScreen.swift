//
//  SplashScreen.swift
//  LakesideTatler
//
//  This is the loading screen for the app
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

    let maroon = UIColor(red: 0.424, green: 0.0, blue: 0.106, alpha: 1.0)
    let gold = UIColor(red: 0.91, green: 0.643, blue: 0.07, alpha: 1.0)
    @IBOutlet weak var logo: UIImageView!
    
    /*
    * Called when view loads
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoImage = UIImage(named: "Logo Small.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        logo.image = logoImage
        logo.tintColor = gold
        
        self.view.backgroundColor = maroon
        
        //Gets list of logs in
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
        
        //Sets time = to the last log in, later checked if > 60 days
        if(timesLoggedIn.isEmpty) {
            lastLogIn = NSDate().timeIntervalSince1970 - 100000000.0
        } else {
            lastLogIn = Double(timesLoggedIn[timesLoggedIn.count - 1].valueForKey("time") as! Int)
        }
        

    
        loadArticles()
        
    }
    
    /* UNCOMMENT WHEN LOG IN BLOCK REMOVED

    
    /*
    * Updates the last time logged in, this is to update users, not to keep track of actual log-ins
    */
    func updateLogIn(lastLogIn: Double) {
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("LogIn",
        inManagedObjectContext:
        managedContext)
        
        
        
        //creates new log in object
        let logInObject = NSManagedObject(entity: entity!,
        insertIntoManagedObjectContext:managedContext)
        logInObject.setValue(Int(NSDate().timeIntervalSince1970), forKey: "time")
        
        var error: NSError?
        do {
        try managedContext.save()
        } catch var error1 as NSError {
        error = error1
        print("Could not save \(error), \(error?.userInfo)")
        }
        
        self.timesLoggedIn.insert(logInObject, atIndex: self.timesLoggedIn.count)
        
        do {
        try managedContext.save()
        } catch _ {
        }
    }

    */
    
    /*
    * Checks to see if connected to the Internet -
    * If connected, calls method to get articles
    */
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
    
    
    /*
    * Calls the XMLRPC API Method getPosts
    * Gets the first 100 posts from the Tatler's website
    */
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
    
    /*
    * This takes the return [NSDictionary] from the XMLRPC function
    * With that [NSDictionary] it parses out and gets:
    *   *return field*: *Description* - *Saved as*
    *   
    *   post_title: Title of the article - name
    *   post_content: Content of the article - content
    *   post_id: ID number of the article - id
    *   post_author: ID number of the author - author
    *   post_thumbnail: if post_thumbnail is not empty sets image=true
    *   post_thumbnail[link]: link to the image - imageLink
    *   post_date: Date of the article
    */
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
            
            
            // Parse Content - takes out HTML tags, extra spaces, etc.
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

            if(content.substringWithRange(Range<String.Index>(start: content.startIndex, end: content.startIndex.advancedBy(1))) == "\n") {
                
                content = content.substringWithRange(Range<String.Index>(start: content.startIndex.advancedBy(1), end: content.endIndex))
            }
            
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
            /* 
            updateLogIn()
            performSegueWithIdentifier("doneLoading", sender: nil)
            */
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

    /*
    * This controls what gets sent between view controllers in a segue
    * This sends the list of articles to either the home or log in screen
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //Segue to the home screen - sends the list of articles and sets getUserList to false
        if(segue.identifier == "doneLoading") {
            let controller = segue.destinationViewController as! ContainerVC
            controller.articles = self.articles
            if((NSDate().timeIntervalSince1970 - lastLogIn) > 5184000.0) {
                controller.getUserList = true
            } else {
                controller.getUserList = false
            }
        }
        //segue to the log in screen - sends the list of articles
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