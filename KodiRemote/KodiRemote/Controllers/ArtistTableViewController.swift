//
//  ArtistTableViewController.swift
//  KodiRemote
//
//  Created by Quixom Technology on 04/01/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class ArtistTableViewController: UITableViewController {

    var artistImages = [String]()
    var artistId = [Int]()
    var artistNames = [String]()
    var imageCache = [String:UIImage]()
    var artistInitials = [String]()
    let backgroundColors = [0xFF2D55, 0x5856D6, 0x007AFF, 0x34AADC, 0x5AC8FA, 0x4CD964, 0xFF3B30, 0xFF9500, 0xFFCC00, 0x8E8E93, 0xC7C7CC, 0xD6CEC3]
    
    var rc: RemoteCalls!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        rc.jsonRpcCall("AudioLibrary.GetArtists", params: "{\"properties\":[\"thumbnail\"]}"){(response: NSDictionary?) in
            self.generateResponse(response!)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.artistNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ArtistsTableViewCell", forIndexPath: indexPath) as! ArtistsTableViewCell
        
        let row = indexPath.row
        cell.artistName.text = self.artistNames[row]
        
        if self.artistImages[row] != "" {
            cell.artistInitial.hidden = true
            let url = NSURL(string: self.artistImages[row])
            
            cell.artistImage.contentMode = .ScaleAspectFit
            
            if let img = self.imageCache[self.artistImages[row]]{
                cell.artistImage.image = img
            }else{
                self.downloadImage(url!, imageURL: cell.artistImage)
            }
        }else{
            cell.imageView?.hidden = true
            let randomColor = backgroundColors[Int(arc4random_uniform(UInt32(backgroundColors.count)))]
            cell.artistInitial.text = self.artistInitials[row]
            cell.artistInitial.backgroundColor = UIColor(hex: randomColor)
        }
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0.0, cell.frame.height - 1, cell.frame.width, 0.5)
        bottomLine.backgroundColor = UIColor.grayColor().CGColor
        cell.layer.addSublayer(bottomLine)
        cell.clipsToBounds = true
        
        return cell
    }
    
    func downloadImage(url: NSURL, imageURL: UIImageView){
        getImageDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                let image = UIImage(data: data)
                self.imageCache[url.absoluteString] = image
                imageURL.image = image
            }
        }
    }
    
    func generateResponse(jsonData: AnyObject){
        let total = jsonData["limits"]!!["total"] as! Int
        
        if total != 0 {
            let artistDetails = jsonData["artists"] as! NSArray
            
            for item in artistDetails{
                let obj = item as! NSDictionary
                for (key, value) in obj {
                    if key as! String == "label" {
                        let name = value as! String
                        self.artistNames.append(name)
                        let index1 = name.startIndex.advancedBy(1)
                        self.artistInitials.append(name.substringToIndex(index1))
                    }
                    
                    if key as! String == "artistid"{
                        self.artistId.append(value as! Int)
                    }
                    
                    if key as! String == "thumbnail"{
                        var thumbnail = value as! String
                        
                        if thumbnail != "" {
                            thumbnail = thumbnail.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
                            self.artistImages.append("http://" + global_ipaddress + ":" + global_port + "/image/" + thumbnail)
                        }else{
                            self.artistImages.append("")
                        }
                    }
                }
            }
        }else {
            // Display No data found message
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowAlbumsByArtist" {
            let destination = segue.destinationViewController as! AlbumsTableViewController
            if let albumIndex = tableView.indexPathForSelectedRow?.row {
                destination.artistId = self.artistId[albumIndex]
                destination.artistName = self.artistNames[albumIndex]
            }
        }
    }

}
