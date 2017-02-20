//
//  NavigationBar.swift
//  SlideoutMenu
//
//  Created by Quixom Technology on 22/02/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import Foundation

class NavigationBar: UITableViewController {
    
    var TableArray = [String]()
    var ImagesArray = [String]()
    
    override func viewDidLoad() {
        TableArray = ["Remote","Movies","TV Shows", "Music", "Mouse", "Add on", "Discover Media", "Cast"]
        ImagesArray = ["Remote", "movie", "video", "music", "Mouse", "Add on", "Devices", "cast"]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableArray[(indexPath as NSIndexPath).row], for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = TableArray[(indexPath as NSIndexPath).row]
        cell.imageView?.image = UIImage(named: ImagesArray[(indexPath as NSIndexPath).row])
        
        /* image resizing */
        let itemSize:CGSize = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
        let imageRect : CGRect = CGRect(x: 0, y: 0, width: itemSize.width, height: itemSize.height)
        cell.imageView!.image?.draw(in: imageRect)
        cell.imageView!.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        cell.textLabel?.textColor = UIColor.black
        
        return cell
    }
    
}
