//
//  TvShowEpisodesController.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 30/03/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import Foundation
import Kingfisher

class TvShowSeasonsController: UITableViewController {
    
    var seasonObjs = NSArray()
    
    var rc: RemoteCalls!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        self.rc.jsonRpcCall("VideoLibrary.GetSeasons", params: "{\"tvshowid\":\(tvshow_id),\"properties\":[\"episode\",\"thumbnail\",\"season\",\"watchedepisodes\"]}"){(response: AnyObject?) in
            
            self.generateSeasonResponse(response as! NSDictionary)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.seasonObjs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TvShowSeasons", for: indexPath) as! TvShowSeasonsTableViewCell
        
        let seasonDetails = self.seasonObjs[(indexPath as NSIndexPath).row] as! NSDictionary
        
        cell.seasonTitle.text = seasonDetails["label"] as? String
        cell.totalEpisodes.text = String(seasonDetails["episode"] as! Int) + " Episodes | "
        cell.watchedEpisodes.text = String(seasonDetails["watchedepisodes"] as! Int) + " watched"
        
        let thumbnail = seasonDetails["thumbnail"] as! String
        let url = URL(string: getThumbnailUrl(thumbnail))
        cell.seasonImage.contentMode = .scaleAspectFit
        cell.seasonImage.kf.setImage(with: url!)
        
        return cell
    }
    
    func generateSeasonResponse(_ jsonData: AnyObject){
        let total = (jsonData["limits"] as! NSDictionary)["total"] as! Int
        
        if total != 0 {
            let seasons = jsonData["seasons"] as! NSArray
            
            self.seasonObjs = seasons
            
        }else {
            // Display No data found message
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSeasonEpisodes" {
            let destination = segue.destination as! TvshowEpisodesController
            if let seasonIndex = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row {
                destination.season = (self.seasonObjs[seasonIndex] as! NSDictionary)["season"] as! Int
                destination.seasonName = (self.seasonObjs[seasonIndex] as! NSDictionary)["label"] as! String
            }
        }
    }

}
