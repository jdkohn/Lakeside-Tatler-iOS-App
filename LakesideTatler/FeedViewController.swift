//
//  FeedViewController.swift
//  LakesideTatler
//
//  This is the home screen's code
//
//
//  Created by Jacob Kohn on 3/16/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit
import wpxmlrpc
import CoreData

class FeedViewController: UITableViewController {
    
    var articles = [NSDictionary]()
    var getUserList = Bool()
    var users = [NSManagedObject]()
    
    var news = [NSDictionary]()
    var entertainment = [NSDictionary]()
    var sports = [NSDictionary]()
    var opinions = [NSDictionary]()
    var arts = [NSDictionary]()
    var reviews = [NSDictionary]()
    var features = [NSDictionary]()
    var technology = [NSDictionary]()
    var lifeculture = [NSDictionary]()
    var uncategorized = [NSDictionary]()
    
    var currentType = Int()
    
    let types = ["all", "uncatagorized", "arts", "opinions", "reviews", "news", "life-culture", "features", "sports", "technology"]
    
    let maroon = UIColor(red: 0.424, green: 0.0, blue: 0.106, alpha: 1.0)
    let gold = UIColor(red: 0.91, green: 0.643, blue: 0.07, alpha: 1.0)
    
    @IBOutlet weak var table: UITableView!
    
    /*
    * This function sorts the articles into different catagories
    * It sets all the catagory NSDictionaries to blank and then populates them
    */
    func sortArticles() {
        news = [NSDictionary]()
        entertainment = [NSDictionary]()
        sports = [NSDictionary]()
        opinions = [NSDictionary]()
        arts = [NSDictionary]()
        reviews = [NSDictionary]()
        features = [NSDictionary]()
        technology = [NSDictionary]()
        lifeculture = [NSDictionary]()
        uncategorized = [NSDictionary]()
        
        for(var i=0; i<articles.count; i++) {
            
            for(var l=0; l<articles[i]["catagories"]!.count; l++) {
                
                if((articles[i]["catagories"]!.objectAtIndex(l) as! String) == "news") {
                    news.append(articles[i])
                }
                if((articles[i]["catagories"]!.objectAtIndex(l) as! String) == "features") {
                    features.append(articles[i])
                }
                if((articles[i]["catagories"]!.objectAtIndex(l) as! String) == "sports") {
                    sports.append(articles[i])
                }
                if((articles[i]["catagories"]!.objectAtIndex(l) as! String) == "opinions") {
                    opinions.append(articles[i])
                }
                if((articles[i]["catagories"]!.objectAtIndex(l) as! String) == "arts") {
                    arts.append(articles[i])
                }
                if((articles[i]["catagories"]!.objectAtIndex(l) as! String) == "life-culture") {
                    lifeculture.append(articles[i])
                }
                if((articles[i]["catagories"]!.objectAtIndex(l) as! String) == "technology") {
                    technology.append(articles[i])
                }
                if((articles[i]["catagories"]!.objectAtIndex(l) as! String) == "uncategorized") {
                    uncategorized.append(articles[i])
                }
                if((articles[i]["catagories"]!.objectAtIndex(l) as! String) == "entertainment") {
                    entertainment.append(articles[i])
                }
                if((articles[i]["catagories"]!.objectAtIndex(l) as! String) == "reviews") {
                    reviews.append(articles[i])
                }
            }
        }
    }
    
    /*
    * This function is called when the page is opened
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sets an observer to know when the menu chooses a new catagory
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeCatagory:", name: "changeCatagory", object: nil)
        
        //loads the authors
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
        users = fetchedResults
        
        //if hasn't updated users in 60 days :
        if(getUserList) {
            
            //if there are no users stored, gets the first thousand
            if(users.isEmpty) {
                getUsers(1000)
            } else {
                
                //deletes all users, then gets total # of users stored + 50
                let num = users.count + 50
                deleteUsers()
                getUsers(num)
            }
        }
        
        //sets the current type = 0 (displays all articles)
        currentType = 0
        
        //connects the table to the code
        table.dataSource = self
        table.delegate = self
        
        //sorts the articles and adds function to the nav bar
        sortArticles()
        configureNavBar()
    }
    
    /*
    * This function deletes all the users/authors stored in CoreData
    */
    func deleteUsers() {
        func deleteIncidents() {
            let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = appDel.managedObjectContext
            let coord = appDel.persistentStoreCoordinator
            
            let fetchRequest = NSFetchRequest(entityName: "User")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try coord.executeRequest(deleteRequest, withContext: context)
            } catch let error as NSError {
                debugPrint(error)
            }
        }
    }
    
    /*
    * This calls the XMLRPC API method getUsers
    * It updates the user list for the app, storing the results in CoreData
    * Paramater: number - The number of users sent to Wordpress to return
    * Stores in Core Data entity User:
    *   id - Wordpress' assigned ID number to the user
    *   name - Name of the user
    */
    func getUsers(number: Int) {
        var url = NSURL()
        url = NSURL(string: "http://tatler.lakesideschool.org/xmlrpc.php")!
        
        var request = NSMutableURLRequest()
        request = NSMutableURLRequest(URL: url)
        
        var session = NSURLSession.sharedSession()
        
        let filter : [String:AnyObject] = [
            "number" : 1000,
        ]
        
        let encoder = WPXMLRPCEncoder(method: "wp.getUsers", andParameters: [0,"jacobk", "14050 1st Ave NE", filter])
        
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
                
                self.parseUsers(decoder.object() as! [NSDictionary])
            })
        }
        task.resume()
    }
    
    /*
    * This method sorts the users
    * Paramater: decoder [NSDictionary] - the key-value array from 
    * Wordpress that was returned from the XMLRPC API call
    */
    func parseUsers(decoder: [NSDictionary]) {
        //Loops through all Users returned from the function
        for(var i=0; i<decoder.count; i++) {
            let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            
            let entity =  NSEntityDescription.entityForName("User",
                inManagedObjectContext:
                managedContext)
            
            
            
            //Stores the user in Core Data
            let userObject = NSManagedObject(entity: entity!,
                insertIntoManagedObjectContext:managedContext)
            userObject.setValue(decoder[i]["display_name"] as! String, forKey: "name")
            userObject.setValue(Int(decoder[i]["user_id"] as! String), forKey: "id")
            
            var error: NSError?
            do {
                try managedContext.save()
            } catch var error1 as NSError {
                error = error1
                print("Could not save \(error), \(error?.userInfo)")
            }
            
            self.users.insert(userObject, atIndex: self.users.count)
            
            do {
                try managedContext.save()
            } catch _ {
            }
        }
    }
    
    /*
    * Called when the notification to change catagories is sent
    * Changes the currentType and reloads table data
    */
    func changeCatagory(notification: NSNotification) {
        let catagory = notification.object as! Int
        
        currentType = catagory
        
        table.reloadData()
    }
    
////////////// MENU FUNCTIONS //////////////
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func openMenu(sender: UIBarButtonItem) {
        NSNotificationCenter.defaultCenter().postNotificationName("toggleMenu", object: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        NSNotificationCenter.defaultCenter().postNotificationName("closeMenuViaNotification", object: nil)
        view.endEditing(true)
    }
    
    func openPushWindow(){
        performSegueWithIdentifier("openPushWindow", sender: nil)
    }
    
//////////////////////////////////////////
    
    
    /*
    * This function configures the nav bar
    * Sets color, items, tint
    */
    func configureNavBar() {
        //let blue = UIColor(red: 0.0, green: 0.0, blue: 0.509, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = maroon
        
        let menuImage = UIImage(named: "menuButtonSlim2.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: menuImage, style: .Plain, target: self, action: "openMenu:")
        self.navigationItem.leftBarButtonItem?.tintColor = gold
        
        let logo = UIImage(named: "lion PNG.png")
        
        let imageView = UIImageView(image: logo)
        
        self.navigationItem.titleView = imageView
        
        self.navigationItem.backBarButtonItem?.tintColor = gold
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    * This is a tableView function - sets number of cells in table
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(currentType == 1) {
            return news.count
        } else if(currentType == 2) {
            return features.count
        } else if(currentType == 3) {
            return entertainment.count
        } else if(currentType == 4) {
            return sports.count
        } else if(currentType == 5) {
            return arts.count
        } else if(currentType == 6) {
            return opinions.count
        } else if(currentType == 7) {
            return lifeculture.count
        } else {
            return articles.count
        }
    }
    
    /*
    * Sets the contents of a cell
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("articleCell", forIndexPath: indexPath) as! ArticleCell
        
        var currentDictionary = NSDictionary()
        
        
        if(currentType == 1) {
            currentDictionary = news[indexPath.row]
        } else if(currentType == 2) {
            currentDictionary = features[indexPath.row]
        } else if(currentType == 3) {
            currentDictionary = entertainment[indexPath.row]
        } else if(currentType == 4) {
            currentDictionary = sports[indexPath.row]
        } else if(currentType == 5) {
            currentDictionary = arts[indexPath.row]
        } else if(currentType == 6) {
            currentDictionary = opinions[indexPath.row]
        } else if(currentType == 7) {
            currentDictionary = lifeculture[indexPath.row]
        } else {
            currentDictionary = articles[indexPath.row]
        }
        
        
        cell.title.text = (currentDictionary.valueForKey("title") as! String)
        
        cell.preview.font = UIFont(name: cell.preview.font.fontName, size: 15)
        
        cell.preview.numberOfLines = 2
        
        cell.preview.text = (currentDictionary.valueForKey("content") as! String)
        
        
        
        cell.preview.frame.size.width = self.view.frame.size.width - 51
        
        return cell
    }
    
    /*
    * This function controls what gets passed in between View Controllers
    * In this instance of the function it sends articles to other View Controllers
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if(segue.identifier == "readArticleWithImage") {
            let controller = segue.destinationViewController as! ArticleViewController
            controller.article = sender as! NSDictionary
        } else if(segue.identifier == "readArticleWithoutImage") {
            let controller = segue.destinationViewController as! NoImageArticleViewController
            controller.article = sender as! NSDictionary
        }
    }
    
    
    /*
    * This is called when a cell is selected
    * It attaches the selected article to the segue to the Article VC
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var article = NSDictionary()
        
        //selects which article the user wants to read
        if(currentType == 1) {
            article = news[indexPath.row]
        } else if(currentType == 2) {
            article = features[indexPath.row]
        } else if(currentType == 3) {
            article = entertainment[indexPath.row]
        } else if(currentType == 4) {
            article = sports[indexPath.row]
        } else if(currentType == 5) {
            article = arts[indexPath.row]
        } else if(currentType == 6) {
            article = opinions[indexPath.row]
        } else if(currentType == 7) {
            article = lifeculture[indexPath.row]
        } else {
            article = articles[indexPath.row]
        }
        
        if(article["image"] as! Bool) {
            self.performSegueWithIdentifier("readArticleWithImage", sender: article)
        } else {
            self.performSegueWithIdentifier("readArticleWithoutImage", sender: article)
        }
        
    }
}