//
//  MoviesTableViewController.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 29/12/15.
//  Copyright © 2015 Quixom Technology. All rights reserved.
//

import Foundation
import Kingfisher

class MoviesTableViewController: BaseTableViewController {

    var movieObjs = NSArray()
    
    var rc: RemoteCalls!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        self.rc.jsonRpcCall("VideoLibrary.GetMovies", params: "{\"properties\":[\"genre\",\"year\",\"thumbnail\",\"runtime\", \"file\"]}"){(response: AnyObject?) in
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
        return self.movieObjs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoviesTableViewCell", for: indexPath) as! MoviesTableViewCell
        
        let movieDetails = self.movieObjs[(indexPath as NSIndexPath).row] as! NSDictionary
        cell.movieLabel.text = movieDetails["label"] as? String
        cell.genreLabel.text = (movieDetails["genre"] as! NSArray).componentsJoined(by: ", ")
        cell.timeLabel.text = String(movieDetails["runtime"] as! Int / 60) + " min"
        cell.yearLabel.text = String(movieDetails["year"] as! Int)
        
        let thumbnail = movieDetails["thumbnail"] as! String
        let url = URL(string: getThumbnailUrl(thumbnail))
        
        cell.movieImage.contentMode = .scaleAspectFit
        cell.movieImage.kf.setImage(with: url!)

        return cell
    }

    func generateResponse(_ jsonData: AnyObject){
        let total = (jsonData["limits"] as! NSDictionary)["total"] as! Int
        
        if total != 0 {
            let moviesDetails = jsonData["movies"] as! NSArray
            
            self.movieObjs = moviesDetails

        }else {
            // Display No data found message
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MovieTabBarController" {
            let movieTabBarC = segue.destination as! UITabBarController
            let destination = movieTabBarC.viewControllers?.first as! MovieDetailsViewController
            if let movieIndex = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row {
                destination.movieid = (self.movieObjs[movieIndex] as! NSDictionary)["movieid"] as! Int
                destination.moviefile = (self.movieObjs[movieIndex] as! NSDictionary)["file"] as! String
                segue.destination.navigationItem.title = (self.movieObjs[movieIndex] as! NSDictionary)["label"] as? String
            }
        }
    }

}
