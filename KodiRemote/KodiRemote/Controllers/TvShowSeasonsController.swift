//
//  TvShowEpisodesController.swift
//  KodiRemote
//
//  Created by Quixom Technology on 30/03/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import Foundation

class TvShowSeasonsController: UITableViewController {

    var seasonImages = [String]()
    var seasonNames = [String]()
    var seasonNumbers = [Int]()
    var totalEpisodes = [String]()
    var watchedEpisodes = [String]()
    var imageCache = [String:UIImage]()
    
    var rc: RemoteCalls!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        self.rc.jsonRpcCall("VideoLibrary.GetSeasons", params: "{\"tvshowid\":\(tvshow_id),\"properties\":[\"episode\",\"thumbnail\",\"season\",\"watchedepisodes\"]}"){(response: AnyObject?) in
            
            self.generateSeasonResponse(response as! NSDictionary)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.seasonNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TvShowSeasons", forIndexPath: indexPath) as! TvShowSeasonsTableViewCell
        
        cell.seasonTitle.text = self.seasonNames[indexPath.row]
        cell.totalEpisodes.text = self.totalEpisodes[indexPath.row]
        cell.watchedEpisodes.text = self.watchedEpisodes[indexPath.row]
        
        let url = NSURL(string: self.seasonImages[indexPath.row])
        cell.seasonImage.contentMode = .ScaleAspectFit
        
        if let img = self.imageCache[self.seasonImages[indexPath.row]]{
            cell.seasonImage.image = img
        }else{
            self.downloadImage(url!, imageURL: cell.seasonImage)
        }
        
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
    
    func generateSeasonResponse(jsonData: AnyObject){
        let total = jsonData["limits"]!!["total"] as! Int
        
        if total != 0 {
            let seasons = jsonData["seasons"] as! NSArray
            
            for item in seasons{
                let obj = item as! NSDictionary
                for (key, value) in obj {
                    if key as! String == "label" {
                        self.seasonNames.append(value as! String)
                    }
                    
                    if key as! String == "episode" {
                        self.totalEpisodes.append(String(value as! Int) + " Episodes |")
                    }
                    
                    if key as! String == "season" {
                        self.seasonNumbers.append(value as! Int)
                    }
                    
                    if key as! String == "watchedepisodes" {
                        self.watchedEpisodes.append(String(value as! Int) + " Watched")
                    }
                    
                    if key as! String == "thumbnail"{
                        var thumbnail = value as! String
                        thumbnail = thumbnail.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
                        self.seasonImages.append("http://" + global_ipaddress + ":" + global_port + "/image/" + thumbnail)
                    }
                }
            }
        }else {
            // Display No data found message
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowSeasonEpisodes" {
            let destination = segue.destinationViewController as! TvshowEpisodesController
            if let seasonIndex = tableView.indexPathForSelectedRow?.row {
                destination.season = self.seasonNumbers[seasonIndex]
                destination.seasonName = self.seasonNames[seasonIndex]
            }
        }
    }

}
