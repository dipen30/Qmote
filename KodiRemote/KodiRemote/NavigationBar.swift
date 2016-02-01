//
//  BackTableVC.swift
//  SlideoutMenu
//
//  Created by Jared Davidson on 4/8/15.
//  Copyright (c) 2015 Archetapp. All rights reserved.
//

import Foundation

class NavigationBar: UITableViewController {
    
    var TableArray = [String]()
    
    override func viewDidLoad() {
        TableArray = ["Remote","Movies","TV Shows", "Music", "Files", "Addons", "Discover Media"]
        
        //tableView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableArray[indexPath.row], forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = TableArray[indexPath.row]
        //cell.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        cell.textLabel?.textColor = UIColor.blackColor()
        return cell
    }
    
}