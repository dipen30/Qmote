//
//  AlbumDetailsTableViewController.swift
//  KodiRemote
//
//  Created by Quixom Technology on 06/01/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class AlbumDetailsTableViewController: UITableViewController {

    var albumId = Int()
    var albumName = String()
    var songsName = [String]()
    var imageCache = [String:UIImage]()
    var songImages = [String]()
    
    var rc: RemoteCalls!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = albumName
        
        rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        rc.jsonRpcCall("AudioLibrary.GetSongs", params: "{\"filter\":{\"albumid\":\(albumId)},\"properties\":[\"thumbnail\",\"genre\",\"artist\"]}"){ (response: AnyObject?) in
            self.generateResponse(response as! NSDictionary)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.songsName.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AlbumDetailsTableViewCell", forIndexPath: indexPath) as! AlbumDetailsTableViewCell
        
        let row = indexPath.row
        cell.songName.text = self.songsName[row]
        
        if self.songImages[row] != "" {
            let url = NSURL(string: self.songImages[row])
            
            cell.songImage.contentMode = .ScaleAspectFit
            
            if let img = self.imageCache[self.songImages[row]]{
                cell.songImage.image = img
            }else{
                self.downloadImage(url!, imageURL: cell.songImage)
            }
        }else{
            /*cell.albumImage.hidden = true
            cell.albumInitial.hidden = false
            let randomColor = backgroundColors[Int(arc4random_uniform(UInt32(backgroundColors.count)))]
            cell.albumInitial.text = self.albumInitials[row]
            cell.albumInitial.backgroundColor = UIColor(hex: randomColor)*/
        }
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0.0, cell.frame.height - 1, cell.frame.width, 0.5)
        bottomLine.backgroundColor = UIColor.grayColor().CGColor
        cell.layer.addSublayer(bottomLine)
        cell.clipsToBounds = true
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.rc.jsonRpcCall("Playlist.clear", params: "{\"playlistid\":0}"){ (response: AnyObject?) in
            self.rc.jsonRpcCall("Playlist.Add", params: "{\"playlistid\":0, \"item\":{\"albumid\":\(self.albumId)}}"){ (response: AnyObject?) in
                self.rc.jsonRpcCall("Player.Open", params: "{\"item\":{\"playlistid\":0, \"position\": \(indexPath.row)}}"){ (response: AnyObject?) in
                }
            }
        }
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
            let albumDetails = jsonData["songs"] as! NSArray
            
            for item in albumDetails{
                let obj = item as! NSDictionary
                for (key, value) in obj {
                    
                    if key as! String == "label" {
                        let name = value as! String
                        self.songsName.append(name)
                    }
                    
                    if key as! String == "thumbnail"{
                        var thumbnail = value as! String
                        
                        if thumbnail != "" {
                            thumbnail = thumbnail.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
                            self.songImages.append("http://" + global_ipaddress + ":" + global_port + "/image/" + thumbnail)
                        }else{
                            self.songImages.append("")
                        }
                    }
                }
            }
        }else {
            // Display No data found message
        }
    }

}
