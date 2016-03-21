//
//  ArticleViewController.swift
//  HaleSentinel
//
//  Created by Jacob Kohn on 2/9/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ArticleViewController: UIViewController, UIScrollViewDelegate {
    
    var article = NSDictionary()
    
    var authors = [NSManagedObject]()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var image = UIImage()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let container = self.parentViewController?.parentViewController as! ContainerVC
        container.scrollView.scrollEnabled = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        
        self.navigationController!.navigationBar.tintColor = UIColor.blackColor()
        
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.blackColor()
        
        titleLabel.text = (article.valueForKey("title") as! String)
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
        
        let imageWidth = NSLayoutConstraint (item: imageView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: self.view.frame.size.width + 4)
        self.view.addConstraint(imageWidth)
        
        let imageHeight = NSLayoutConstraint (item: imageView,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: self.view.frame.size.width / 2)
        self.view.addConstraint(imageHeight)
        
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x>0 {
            scrollView.contentOffset.x = 0
        }
        
        if scrollView.contentOffset.x<0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let container = self.parentViewController?.parentViewController as! ContainerVC
        container.scrollView.scrollEnabled = true
    }
    

    
    func configureNavBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        let logo = UIImage(named: "topLogo.png")
        
        let imageView = UIImageView(image:logo)
        
        self.navigationItem.titleView = imageView
        
    }
    
    func goHome(sender: UIScreenEdgePanGestureRecognizer) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            if(self.article["image"] as! Bool) {
                if let url = NSURL(string: self.article["imageLink"] as! String) {
                    if let data = NSData(contentsOfURL: url) {
                            self.image = UIImage(data: data)!
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.imageView.image = self.image
            })
        })
    
    }
    
    func home(sender: UIBarButtonItem) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}