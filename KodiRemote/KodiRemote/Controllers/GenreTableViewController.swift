//
//  GenreTableViewController.swift
//  KodiRemote
//
//  Created by Quixom Technology on 05/01/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class GenreTableViewController: UITableViewController {

    var genreNames = [String]()
    var genreIds = [Int]()
    var genreInitials = [String]()
    let backgroundColors = [0xFF2D55, 0x5856D6, 0x007AFF, 0x34AADC, 0x5AC8FA, 0x4CD964, 0xFF3B30, 0xFF9500, 0xFFCC00, 0x8E8E93, 0xC7C7CC, 0xD6CEC3]
    
    var rc: RemoteCalls!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        rc.jsonRpcCall("AudioLibrary.GetGenres", params: "{\"properties\":[]}"){ (response: AnyObject?) in
            self.generateResponse(response as! NSDictionary)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.genreNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GenreTableViewCell", forIndexPath: indexPath) as! GenreTableViewCell
        
        let row = indexPath.row
        cell.genreName.text = self.genreNames[row]
        
        let randomColor = backgroundColors[Int(arc4random_uniform(UInt32(backgroundColors.count)))]
        cell.genreInitial.text = self.genreInitials[row]
        cell.genreInitial.backgroundColor = UIColor(hex: randomColor)
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0.0, cell.frame.height - 1, cell.frame.width, 0.5)
        bottomLine.backgroundColor = UIColor.grayColor().CGColor
        cell.layer.addSublayer(bottomLine)
        cell.clipsToBounds = true
        
        return cell
    }
    
    func generateResponse(jsonData: AnyObject){
        let total = jsonData["limits"]!!["total"] as! Int
        
        if total != 0 {
            let albumDetails = jsonData["genres"] as! NSArray
            
            for item in albumDetails{
                let obj = item as! NSDictionary
                for (key, value) in obj {
                    if key as! String == "label" {
                        let name = value as! String
                        self.genreNames.append(name)
                        let index1 = name.startIndex.advancedBy(1)
                        self.genreInitials.append(name.substringToIndex(index1))
                    }
                    
                    if key as! String == "genreid"{
                        self.genreIds.append(value as! Int)
                    }
                }
            }
        }else {
            // Display No data found message
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowAlbumsByGenre" {
            let destination = segue.destinationViewController as! AlbumsTableViewController
            if let albumIndex = tableView.indexPathForSelectedRow?.row {
                destination.artistId = self.genreIds[albumIndex]
                destination.artistName = self.genreNames[albumIndex]
            }
        }
    }
}
