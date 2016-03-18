//
//  Menu.swift
//  HaleSentinel
//
//  Created by Jacob Kohn on 2/10/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit

class Menu : UITableViewController {
    
    let menuOptions = ["All", "News", "Features", "Entertainment", "Sports", "Arts", "Opinions", "Reviews", "Technology", "Life & Culture", "Uncatagorized"]
    
    override func viewDidLoad() {
        configureNavBar()
    }
    
    func configureNavBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        let logo = UIImage(named: "topLogo.png")
        
        let imageView = UIImageView(image:logo)
        
        self.navigationItem.titleView = imageView
        
    }


}

// MARK: - UITableViewDelegate methods

extension Menu {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        NSNotificationCenter.defaultCenter().postNotificationName("changeCatagory", object: indexPath.row)
        
        // also close the menu
        NSNotificationCenter.defaultCenter().postNotificationName("closeMenuViaNotification", object: nil)
        
    }
    
}

// MARK: - UITableViewDataSource methods

extension Menu {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuOptions.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = menuOptions[indexPath.row]
        
        
        return cell
    }
    
}