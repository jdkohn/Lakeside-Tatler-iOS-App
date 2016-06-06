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
    
    let maroon = UIColor(red: 0.424, green: 0.0, blue: 0.106, alpha: 1.0)
    let gold = UIColor(red: 0.91, green: 0.643, blue: 0.07, alpha: 1.0)
    
    let menuOptions = ["All", "News", "Features", "Entertainment", "Sports", "Arts & Entertainment", "Opinions", "Life & Culture"]
    
    override func viewDidLoad() {
        self.view.backgroundColor = maroon
        
        configureNavBar()
    }
    
    func configureNavBar() {
        self.navigationController?.navigationBar.barTintColor = maroon
        
        let logo = UIImage(named: "lion PNG.png")
        
        let imageView = UIImageView(image: logo)
        
        self.navigationItem.titleView = imageView
        
        self.navigationItem.backBarButtonItem?.tintColor = gold
        
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
        
        cell.backgroundColor = maroon
        cell.tintColor = gold
        cell.textLabel?.textColor = gold
        
        return cell
    }
    
}