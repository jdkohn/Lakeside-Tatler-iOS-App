//
//  LogInScreen.swift
//  LakesideTatler
//
//  Created by Jacob Kohn on 3/15/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit

class LogInViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logInButton.addTarget(self, action: "logIn:", forControlEvents: .TouchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logIn(sender: UIButton) {
        
        let username = usernameField.text!
        let password = passwordField.text!
        
        var responseString = "" as! NSString
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://tatler.lakesideschool.org/wp-login.php")!)
        request.HTTPMethod = "POST"
        let postString = "log=" + username + "&pwd=" + password + "&wp-submit=Log%20In&redirect_to=http://tatler.lakesideschool.org/"
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
            
            dispatch_async(dispatch_get_main_queue()) {
                if((responseString).rangeOfString("<div id=\"login_error\">").location == NSNotFound) {
                    print("Log In Success!")
                    self.usernameField.text! = ""
                    self.passwordField.text! = ""
                } else {
                    print("Log In Fail")
                    self.usernameField.text! = ""
                    self.passwordField.text! = ""
                }
            }
            
        }
        task.resume()
        
        
    }
}