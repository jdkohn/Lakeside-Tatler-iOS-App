//
//  FeedViewController.swift
//  LakesideTatler
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
    
    @IBOutlet weak var table: UITableView!
    
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
                
                if((articles[i]["catagories"]![l] as! String) == "news") {
                    news.append(articles[i])
                }
                if((articles[i]["catagories"]![l] as! String) == "features") {
                    features.append(articles[i])
                }
                if((articles[i]["catagories"]![l] as! String) == "sports") {
                    sports.append(articles[i])
                }
                if((articles[i]["catagories"]![l] as! String) == "opinions") {
                    opinions.append(articles[i])
                }
                if((articles[i]["catagories"]![l] as! String) == "arts") {
                    arts.append(articles[i])
                }
                if((articles[i]["catagories"]![l] as! String) == "life-culture") {
                    lifeculture.append(articles[i])
                }
                if((articles[i]["catagories"]![l] as! String) == "technology") {
                    technology.append(articles[i])
                }
                if((articles[i]["catagories"]![l] as! String) == "uncategorized") {
                    uncategorized.append(articles[i])
                }
                if((articles[i]["catagories"]![l] as! String) == "entertainment") {
                    entertainment.append(articles[i])
                }
                if((articles[i]["catagories"]![l] as! String) == "reviews") {
                    reviews.append(articles[i])
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeCatagory:", name: "changeCatagory", object: nil)
        
        
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
        
        if(getUserList) {
            if(users.isEmpty) {
                getUsers(1000)
            } else {
                let num = users.count + 50
                deleteUsers()
                getUsers(num)
            }
        }
        
        currentType = 0
        
        table.dataSource = self
        table.delegate = self
        
        print("opened")
        
        sortArticles()
        configureNavBar()
    }
    
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
    
    
    func getUsers(number: Int) {
        var url = NSURL()
        url = NSURL(string: "http://tatler.lakesideschool.org/xmlrpc.php")!
        
        var request = NSMutableURLRequest()
        request = NSMutableURLRequest(URL: url)
        
        var session = NSURLSession.sharedSession()
        
        let filter : [String:AnyObject] = [
            "number" : number,
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
    
    func parseUsers(decoder: [NSDictionary]) {
        for(var i=0; i<decoder.count; i++) {
            let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            
            let entity =  NSEntityDescription.entityForName("User",
                inManagedObjectContext:
                managedContext)
            
            
            
            //creates new password object
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
    
    func changeCatagory(notification: NSNotification) {
        let catagory = notification.object as! Int
        
        currentType = catagory
        
        table.reloadData()
    }
    
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
    
    
    func configureNavBar() {
        let blue = UIColor(red: 0.0, green: 0.0, blue: 0.509, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        let logo = UIImage(named: "h2.png")
        
        let menuImage = UIImage(named: "menuButtonSlim2.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: menuImage, style: .Plain, target: self, action: "openMenu:")
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.blackColor()
        
        let imageView = UIImageView(image:logo)
        
        self.navigationItem.titleView = imageView
        //self.navigationItem.titleView?.tintColor = UIColor.blackColor()
        
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.blackColor()
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
            return reviews.count
        } else if(currentType == 8) {
            return technology.count
        } else if(currentType == 9) {
            return lifeculture.count
        } else if(currentType == 10) {
            return uncategorized.count
        } else {
            return articles.count
        }
    }
    
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
            currentDictionary = reviews[indexPath.row]
        } else if(currentType == 8) {
            currentDictionary = technology[indexPath.row]
        } else if(currentType == 9) {
            currentDictionary = lifeculture[indexPath.row]
        } else if(currentType == 10) {
            currentDictionary = uncategorized[indexPath.row]
        } else {
            currentDictionary = articles[indexPath.row]
        }
        
        
        cell.title.text = (currentDictionary.valueForKey("title") as! String)
        
        cell.preview.text = (currentDictionary.valueForKey("content") as! String)
        
        cell.preview.frame.size.width = self.view.frame.size.width - 51
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if(segue.identifier == "readArticleWithImage") {
            let controller = segue.destinationViewController as! ArticleViewController
            controller.article = sender as! NSDictionary
        } else if(segue.identifier == "readArticleWithoutImage") {
            let controller = segue.destinationViewController as! NoImageArticleViewController
            controller.article = sender as! NSDictionary
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
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
            article = reviews[indexPath.row]
        } else if(currentType == 8) {
            article = technology[indexPath.row]
        } else if(currentType == 9) {
            article = lifeculture[indexPath.row]
        } else if(currentType == 10) {
            article = uncategorized[indexPath.row]
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
