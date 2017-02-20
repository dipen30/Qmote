//
//  TvShowsTableViewController.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 22/02/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class TvShowsTableViewController: BaseTableViewController {

    var tvShowObjs = NSArray()
    
    var rc: RemoteCalls!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        self.rc.jsonRpcCall("VideoLibrary.GetTVShows", params: "{\"properties\":[\"title\",\"thumbnail\",\"episode\",\"premiered\",\"watchedepisodes\"]}"){(response: AnyObject?) in
            self.generateResponse(response as! NSDictionary)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tvShowObjs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TvShowTableViewCell", for: indexPath) as! TvShowTableViewCell
        
        let tvShowDetails = self.tvShowObjs[(indexPath as NSIndexPath).row] as! NSDictionary
        cell.tvshowlabel.text = tvShowDetails["label"] as? String
        cell.totalEpisodes.text = String(tvShowDetails["episode"] as! Int) + " Episodes | " + String(tvShowDetails["watchedepisodes"] as! Int) + " watched"
        cell.premiered.text = tvShowDetails["premiered"] as? String
        
        let thumbnail = tvShowDetails["thumbnail"] as! String
        let url = URL(string: getThumbnailUrl(thumbnail))
        
        cell.tvshowImage.contentMode = .scaleAspectFit
        cell.tvshowImage.kf.setImage(with: url!)
        
        return cell
    }
    
    func generateResponse(_ jsonData: AnyObject){
        let total = (jsonData["limits"] as! NSDictionary)["total"] as! Int
        
        if total != 0 {
            let tvShows = jsonData["tvshows"] as! NSArray
            
            self.tvShowObjs = tvShows

        }else {
            // Display No data found message
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TvShowTabBarController" {
            let tvTabBarC = segue.destination as! UITabBarController
            let destination = tvTabBarC.viewControllers?.first as! TvShowDetailsController
            if let tvShowIndex = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row {
                destination.tvshowid = (self.tvShowObjs[tvShowIndex] as! NSDictionary)["tvshowid"] as! Int
                segue.destination.navigationItem.title = (self.tvShowObjs[tvShowIndex] as! NSDictionary)["label"] as? String
            }
        }
    }

}
