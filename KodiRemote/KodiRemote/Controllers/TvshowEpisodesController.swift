//
//  TvshowEpisodesController.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 01/04/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class TvshowEpisodesController: UITableViewController {

    var episodesObj = NSArray()
    var season = Int()
    var seasonName = String()
    
    var rc: RemoteCalls!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = seasonName
        
        self.rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        self.rc.jsonRpcCall("VideoLibrary.GetEpisodes", params: "{\"tvshowid\":\(tvshow_id),\"season\":\(season), \"properties\":[\"title\",\"thumbnail\",\"firstaired\",\"runtime\",\"episode\",\"file\"]}"){(response: AnyObject?) in
            
            self.generateSeasonResponse(response as! NSDictionary)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.episodesObj.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SeasonEpisodes", for: indexPath) as! TvShowEpisodesViewCell

        let episodeDetails = self.episodesObj[(indexPath as NSIndexPath).row] as! NSDictionary

        cell.episodeTitle.text = episodeDetails["title"] as? String
        cell.episodeAired.text = " | " + (episodeDetails["firstaired"] as! String)
        cell.episodeNumber.text = String(episodeDetails["episode"] as! Int)
        
        let thumbnail = episodeDetails["thumbnail"] as! String
        
        let url = URL(string: getThumbnailUrl(thumbnail))
        cell.episodeImage.contentMode = .scaleAspectFit
        cell.episodeImage.kf.setImage(with: url!)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.episodesObj[(indexPath as NSIndexPath).row] as! NSDictionary
        self.rc.jsonRpcCall("Player.Open", params: "{\"item\":{\"episodeid\":\(episode["episodeid"] as! Int)}}"){ (response: AnyObject?) in
        }
    }
    
    func generateSeasonResponse(_ jsonData: AnyObject){
        let total = (jsonData["limits"] as! NSDictionary)["total"] as! Int
        
        if total != 0 {
            let seasons = jsonData["episodes"] as! NSArray
            
            self.episodesObj = seasons

        }else {
            // Display No data found message
        }
    }
}
