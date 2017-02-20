//
//  ArtistTableViewController.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 04/01/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class ArtistTableViewController: UITableViewController {

    var artistObjs = NSArray()
    
    var rc: RemoteCalls!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        rc.jsonRpcCall("AudioLibrary.GetArtists", params: "{\"properties\":[\"thumbnail\"]}"){(response: AnyObject?) in
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
        return self.artistObjs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistsTableViewCell", for: indexPath) as! ArtistsTableViewCell

        let artistDetails = self.artistObjs[(indexPath as NSIndexPath).row] as! NSDictionary
        cell.artistName.text = artistDetails["label"] as? String
        
        let thumbnail = artistDetails["thumbnail"] as! String
        
        if thumbnail != "" {
            cell.artistInitial.isHidden = true
            let url = URL(string: getThumbnailUrl(thumbnail))
            
            cell.artistImage.contentMode = .scaleAspectFit
            cell.artistImage.kf.setImage(with: url!)
            
        }else{
            cell.imageView?.isHidden = true
            let randomColor = backgroundColors[Int(arc4random_uniform(UInt32(backgroundColors.count)))]
            
            let name = artistDetails["label"] as! String
            let index1 = name.characters.index(name.startIndex, offsetBy: 1)
            
            cell.artistInitial.text = name.substring(to: index1)
            cell.artistInitial.backgroundColor = UIColor(hex: randomColor)
        }
        
        return cell
    }
    
    func generateResponse(_ jsonData: AnyObject){
        let total = (jsonData["limits"] as! NSDictionary)["total"] as! Int
        
        if total != 0 {
            let artistDetails = jsonData["artists"] as! NSArray
            
            self.artistObjs = artistDetails
        }else {
            // Display No data found message
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAlbumsByArtist" {
            let destination = segue.destination as! AlbumsTableViewController
            if let albumIndex = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row {
                destination.artistId = (self.artistObjs[albumIndex] as! NSDictionary)["artistid"] as! Int
                destination.artistName = (self.artistObjs[albumIndex] as! NSDictionary)["label"] as! String
            }
        }
    }

}
