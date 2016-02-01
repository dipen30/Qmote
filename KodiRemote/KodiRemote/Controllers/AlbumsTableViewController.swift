//
//  AlbumsTableViewController.swift
//  KodiRemote
//
//  Created by Quixom Technology on 05/01/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class AlbumsTableViewController: UITableViewController {

    var artistId = Int()
    var artistName = String()
    var genreId = Int()
    var genreName = String()
    var albumImages = [String]()
    var albumIds = [Int]()
    var albumNames = [String]()
    var albumGenres = [String]()
    var albumArtists = [String]()
    var imageCache = [String:UIImage]()
    var albumInitials = [String]()
    let backgroundColors = [0xFF2D55, 0x5856D6, 0x007AFF, 0x34AADC, 0x5AC8FA, 0x4CD964, 0xFF3B30, 0xFF9500, 0xFFCC00, 0x8E8E93, 0xC7C7CC, 0xD6CEC3]
    
    var rc: RemoteCalls!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var params = ""
        if artistId != 0{
            params = "\"filter\":{\"artistid\":\(artistId)},"
            self.navigationItem.title = artistName
        }
        
        if genreId != 0{
            params = "\"filter\":{\"genreid\":\(genreId)},"
            self.navigationItem.title = genreName
        }
        
        rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        rc.jsonRpcCall("AudioLibrary.GetAlbums", params: "{\(params)\"properties\":[\"thumbnail\",\"genre\",\"artist\"]}"){ (response: NSDictionary?) in
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
        return self.albumNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AlbumsTableViewCell", forIndexPath: indexPath) as! AlbumsTableViewCell
        
        let row = indexPath.row
        cell.albumName.text = self.albumNames[row]
        cell.albumGenre.text = self.albumGenres[row]
        cell.albumArtists.text = self.albumArtists[row]
        
        if self.albumImages[row] != "" {
            cell.albumInitial.hidden = true
            let url = NSURL(string: self.albumImages[row])
            
            cell.albumImage.contentMode = .ScaleAspectFit
            
            if let img = self.imageCache[self.albumImages[row]]{
                cell.albumImage.image = img
            }else{
                self.downloadImage(url!, imageURL: cell.albumImage)
            }
        }else{
            cell.albumImage.hidden = true
            cell.albumInitial.hidden = false
            let randomColor = backgroundColors[Int(arc4random_uniform(UInt32(backgroundColors.count)))]
            cell.albumInitial.text = self.albumInitials[row]
            cell.albumInitial.backgroundColor = UIColor(hex: randomColor)
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func generateResponse(jsonData: AnyObject){
        let total = jsonData["limits"]!!["total"] as! Int
        
        if total != 0 {
            let albumDetails = jsonData["albums"] as! NSArray
            
            for item in albumDetails{
                let obj = item as! NSDictionary
                for (key, value) in obj {
                    if key as! String == "albumid"{
                        self.albumIds.append(value as! Int)
                    }
                    
                    if key as! String == "label" {
                        let name = value as! String
                        self.albumNames.append(name)
                        let index1 = name.startIndex.advancedBy(1)
                        self.albumInitials.append(name.substringToIndex(index1))
                    }
                    
                    if key as! String == "genre"{
                        self.albumGenres.append(value.componentsJoinedByString(""))
                    }
                    
                    if key as! String == "artist"{
                        self.albumArtists.append(value.componentsJoinedByString(""))
                    }
                    
                    if key as! String == "thumbnail"{
                        var thumbnail = value as! String
                        
                        if thumbnail != "" {
                            thumbnail = thumbnail.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
                            self.albumImages.append("http://" + global_ipaddress + ":" + global_port + "/image/" + thumbnail)
                        }else{
                            self.albumImages.append("")
                        }
                    }
                }
            }
        }else {
            // Display No data found message
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowAlbumDetails" {
            let destination = segue.destinationViewController as! AlbumDetailsTableViewController
            if let albumIndex = tableView.indexPathForSelectedRow?.row {
                destination.albumId = self.albumIds[albumIndex]
                destination.albumName = self.albumNames[albumIndex]
            }
        }
    }

}
