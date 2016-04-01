//
//  TvshowEpisodesController.swift
//  KodiRemote
//
//  Created by Quixom Technology on 01/04/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class TvshowEpisodesController: UITableViewController {

    var episodeImages = [String]()
    var episodeTitles = [String]()
    var episodeNumbers = [String]()
    var episodeFiles = [String]()
    var runtimes = [String]()
    var episodesAired = [String]()
    var imageCache = [String:UIImage]()
    var season = Int()
    var seasonName = String()
    
    var rc: RemoteCalls!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = seasonName
        
        self.rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        self.rc.jsonRpcCall("VideoLibrary.GetEpisodes", params: "{\"tvshowid\":\(tvshow_id),\"season\":\(season), \"properties\":[\"title\",\"thumbnail\",\"firstaired\",\"runtime\",\"episode\",\"file\"]}"){(response: AnyObject?) in
            
            self.generateSeasonResponse(response as! NSDictionary)
            
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
        return self.episodeTitles.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SeasonEpisodes", forIndexPath: indexPath) as! TvShowEpisodesViewCell

        cell.episodeTitle.text = self.episodeTitles[indexPath.row]
        cell.episodeAired.text = self.episodesAired[indexPath.row]
        cell.episodeNumber.text = self.episodeNumbers[indexPath.row]
        
        let url = NSURL(string: self.episodeImages[indexPath.row])
        cell.episodeImage.contentMode = .ScaleAspectFit
        
        if let img = self.imageCache[self.episodeImages[indexPath.row]]{
            cell.episodeImage.image = img
        }else{
            self.downloadImage(url!, imageURL: cell.episodeImage)
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.rc.jsonRpcCall("Player.Open", params: "{\"item\":{\"file\":\"\(self.episodeFiles[indexPath.row])\"}}"){ (response: AnyObject?) in
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
    
    func generateSeasonResponse(jsonData: AnyObject){
        let total = jsonData["limits"]!!["total"] as! Int
        
        if total != 0 {
            let seasons = jsonData["episodes"] as! NSArray
            
            for item in seasons{
                let obj = item as! NSDictionary
                for (key, value) in obj {
                    if key as! String == "title" {
                        self.episodeTitles.append(value as! String)
                    }
                    
                    if key as! String == "episode" {
                        self.episodeNumbers.append(String(value as! Int))
                    }
                    
                    if key as! String == "firstaired" {
                        self.episodesAired.append(" | " + (value as! String))
                    }
                    
                    if key as! String == "runtime" {
                        let runtime = value as! Int / 60
                        self.runtimes.append(String(runtime) + " min")
                    }
                    
                    if key as! String == "file" {
                        var file_name = value as! String
                        if file_name.hasPrefix("http") || file_name.hasPrefix("plugin"){
                            self.episodeFiles.append(file_name)
                        }else{
                            file_name = file_name.stringByReplacingOccurrencesOfString("\\", withString: "/")
                            self.episodeFiles.append(file_name)
                        }
                    }
                    
                    if key as! String == "thumbnail"{
                        var thumbnail = value as! String
                        thumbnail = thumbnail.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
                        self.episodeImages.append("http://" + global_ipaddress + ":" + global_port + "/image/" + thumbnail)
                    }
                }
            }
        }else {
            // Display No data found message
        }
    }
}
