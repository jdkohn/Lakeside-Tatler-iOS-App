//
//  ViewController.swift
//  LakesideTatler
//
//  Created by Jacob Kohn on 3/7/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        
        
        var responseString = "" as! NSString
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://tatler.lakesideschool.org/wp-login.php")!)
        request.HTTPMethod = "POST"
        let postString = "log=student&pwd=lio&wp-submit=Log%20In&redirect_to=http://tatler.lakesideschool.org/"
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
            print("responseString = \(responseString)")
            
            dispatch_async(dispatch_get_main_queue()) {
                
            }
            
        }
        task.resume()

        
        
    }
    
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

