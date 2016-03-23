//
//  NoImageArticleViewController.swift
//  LakesideTatler
//
//  Created by Jacob Kohn on 3/16/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class NoImageArticleViewController: UIViewController, UIScrollViewDelegate {
    
    var article = NSDictionary()
    
    var authors = [NSManagedObject]()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var image = UIImage()
    
    let maroon = UIColor(red: 0.424, green: 0.0, blue: 0.106, alpha: 1.0)
    let gold = UIColor(red: 0.91, green: 0.643, blue: 0.07, alpha: 1.0)
    
    /*
    * Disables scrolling menu
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let container = self.parentViewController?.parentViewController as! ContainerVC
        container.scrollView.scrollEnabled = false
    }
    
    
    /*
    * Gets content ready for user
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        print(article)
        
        self.navigationController!.navigationBar.tintColor = UIColor.blackColor()
        
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.blackColor()
        
        titleLabel.text = (article["title"] as! String)
        contentLabel.text = (article.valueForKey("content") as! String)
        
        let widthConstraint = NSLayoutConstraint (item: contentLabel,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: self.view.frame.size.width - 16)
        self.view.addConstraint(widthConstraint)
        
        let titleWidth = NSLayoutConstraint (item: titleLabel,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: self.view.frame.size.width - 16)
        self.view.addConstraint(titleWidth)
        
        contentLabel.sizeToFit()
        
        scrollView.scrollEnabled = true
        
        getAuthors()
        
        var labelSet = false
        for(var i=0; i<authors.count; i++) {
            if(String(authors[i].valueForKey("id") as! Int) == (article["author"] as! String)) {
                authorLabel.text = "By: " + (authors[i].valueForKey("name") as! String)
                labelSet = true
                break;
            }
        }
        if(!labelSet) {
            authorLabel.text = ""
        }
        dateLabel.text = (article["date"] as! String)
        
        
        configureNavBar()
    }
    
    /*
    * Loads authors from CoreData
    */
    func getAuthors() {
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
        authors = fetchedResults
    }
    
    /*
    * Scroll view function
    */
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x>0 {
            scrollView.contentOffset.x = 0
        }
        
        if scrollView.contentOffset.x<0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    /*
    * Resets the scroll view of the container view controller to scrollable
    */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let container = self.parentViewController?.parentViewController as! ContainerVC
        container.scrollView.scrollEnabled = true
    }
    
    
    /*
    * Configures the nav bar, sets color, header
    */
    func configureNavBar() {
        self.navigationController?.navigationBar.barTintColor = maroon
        
        let logo = UIImage(named: "lion PNG.png")
        
        let imageView = UIImageView(image: logo)
        
        self.navigationItem.titleView = imageView
        
        self.navigationItem.backBarButtonItem?.tintColor = gold
        
        self.navigationController?.navigationBar.tintColor = gold
    }
    
    /*
    * Goes to home when user pans from left edge, right
    */
    func goHome(sender: UIScreenEdgePanGestureRecognizer) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true);
    }
    
    /*
    * Returns home when a bar button is pressed
    */
    func home(sender: UIBarButtonItem) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}