//
//  LogInScreen.swift
//  LakesideTatler
//
//  This is the log in screen
//
//  Created by Jacob Kohn on 3/15/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class LogInViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var logo: UIImageView!
    
    var articles = [NSDictionary]()
    var timesLoggedIn = [NSManagedObject]()
    
    let maroon = UIColor(red: 0.424, green: 0.0, blue: 0.106, alpha: 1.0)
    let gold = UIColor(red: 0.91, green: 0.643, blue: 0.07, alpha: 1.0)
    let fadedMaroon = UIColor(red: 0.424, green: 0.0, blue: 0.106, alpha: 0.75)
    let fadedGold = UIColor(red: 0.91, green: 0.643, blue: 0.07, alpha: 0.75)
    
    
    /*
    * Called when the view loads
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoImage = UIImage(named: "Logo Small.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        logo.image = logoImage
        logo.tintColor = gold
        
        logInButton.addTarget(self, action: "logIn:", forControlEvents: .TouchUpInside)
        
        self.view.backgroundColor = maroon
        usernameField.backgroundColor = maroon
        usernameField.textColor = gold
        passwordField.backgroundColor = maroon
        passwordField.textColor = gold
        logInButton.tintColor = gold
        usernameField.layer.borderWidth = 1
        usernameField.layer.borderColor = gold.CGColor
        passwordField.layer.borderWidth = 1
        passwordField.layer.borderColor = gold.CGColor
        
        usernameField.attributedPlaceholder = NSAttributedString(string:"Username",
            attributes:[NSForegroundColorAttributeName: fadedGold])
        passwordField.attributedPlaceholder = NSAttributedString(string:"Password",
            attributes:[NSForegroundColorAttributeName: fadedGold])
        
        self.hideKeyboardWhenTappedAround()
        
        //gets list of times that the app has been logged in to
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
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    * This function is called when the User clicks the log in button
    */
    func logIn(sender: UIButton) {
        
        //get the contents of the text fields
        let username = usernameField.text!
        let password = passwordField.text!
        
        var responseString = "" as! NSString
        
        /*
        * Make a POST request to the login page
        * posts username and password entered and submits the form
        */
        let request = NSMutableURLRequest(URL: NSURL(string: "http://tatler.lakesideschool.org/wp-login.php")!)
        request.HTTPMethod = "POST"
        let postString = "log=" + username + "&pwd=" + password + "&wp-submit=Log%20In"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {            // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {  // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
            //print("responseString = \(responseString)")
            
            //dispatch_async function runs after the request is made
            
            dispatch_async(dispatch_get_main_queue()) {
                
                //checks to see if the page post-login contains a 'login error'
                if((responseString).rangeOfString("<div id=\"login_error\">").location == NSNotFound) {
                    
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
                    
                    //goes to home screen
                    
                   self.performSegueWithIdentifier("loggedIn", sender: nil)
                } else {
                    
                    //if the user failed the log in attempt
                    
                    let alert = UIAlertController(title: "Oops!", message: "Incorrect Username/Password", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { (action) -> Void in
                
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)

                }
            }
            
        }
        task.resume()
    }
    
    /*
    * Called when segue is moved, sends articles to Home VC
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "loggedIn") {
            let controller = segue.destinationViewController as! ContainerVC
            controller.articles = self.articles
            controller.getUserList = true
        }
    }
    
}