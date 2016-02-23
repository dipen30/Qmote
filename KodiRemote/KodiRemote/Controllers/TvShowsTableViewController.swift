//
//  TvShowsTableViewController.swift
//  KodiRemote
//
//  Created by Quixom Technology on 22/02/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class TvShowsTableViewController: BaseTableViewController {

    var tvShowIds = [Int]()
    var tvShowImages = [String]()
    var tvShowNames = [String]()
    var tvShowEpisodes = [String]()
    var tvshowWatchedepisodes = [String]()
    var tvShowPremiered = [String]()
    var imageCache = [String:UIImage]()
    
    var rc: RemoteCalls!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: use shared preference to get ip address and port.
        self.rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        self.rc.jsonRpcCall("VideoLibrary.GetTVShows", params: "{\"properties\":[\"title\",\"thumbnail\",\"episode\",\"premiered\",\"watchedepisodes\"]}"){(response: AnyObject?) in
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
        return self.tvShowNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TvShowTableViewCell", forIndexPath: indexPath) as! TvShowTableViewCell
        
        let row = indexPath.row
        cell.tvshowlabel.text = self.tvShowNames[row]
        cell.totalEpisodes.text = self.tvShowEpisodes[row] + self.tvshowWatchedepisodes[row]
        cell.premiered.text = self.tvShowPremiered[row]
        
        let url = NSURL(string: self.tvShowImages[row])
        
        cell.tvshowImage.contentMode = .ScaleAspectFit
        
        if let img = self.imageCache[self.tvShowImages[row]]{
            cell.tvshowImage.image = img
        }else{
            self.downloadImage(url!, imageURL: cell.tvshowImage)
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
            let tvShows = jsonData["tvshows"] as! NSArray
            
            for item in tvShows {
                let obj = item as! NSDictionary
                for (key, value) in obj {
                    if key as! String == "label" {
                        self.tvShowNames.append(value as! String)
                    }
                    
                    if key as! String == "episode" {
                        let episodes = value as! Int
                        self.tvShowEpisodes.append(String(episodes)+" Episodes | ")
                    }
                    
                    if key as! String == "watchedepisodes" {
                        let episodes = value as! Int
                        self.tvshowWatchedepisodes.append(String(episodes)+" watched")
                    }
                    
                    if key as! String == "premiered" {
                        self.tvShowPremiered.append(value as! String)
                    }
                    
                    if key as! String == "tvshowid" {
                        self.tvShowIds.append(value as! Int)
                    }
                    
                    if key as! String == "thumbnail"{
                        var thumbnail = value as! String
                        thumbnail = thumbnail.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
                        self.tvShowImages.append("http://" + global_ipaddress + ":" + global_port + "/image/" + thumbnail)
                    }
                }
            }
        }else {
            // Display No data found message
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TvShowTabBarController" {
            let tvTabBarC = segue.destinationViewController as! UITabBarController
            let destination = tvTabBarC.viewControllers?.first as! TvShowDetailsController
            if let tvShowIndex = tableView.indexPathForSelectedRow?.row {
                destination.tvshowid = self.tvShowIds[tvShowIndex]
            }
        }
    }

}
