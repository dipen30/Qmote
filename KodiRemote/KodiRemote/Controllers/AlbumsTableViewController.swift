//
//  AlbumsTableViewController.swift
//  Kodi Remote 
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
    
    var albumObjs = NSArray()
    
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
        rc.jsonRpcCall("AudioLibrary.GetAlbums", params: "{\(params)\"properties\":[\"thumbnail\",\"genre\",\"artist\"]}"){ (response: AnyObject?) in
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
        return self.albumObjs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumsTableViewCell", for: indexPath) as! AlbumsTableViewCell

        let albumDetails = self.albumObjs[(indexPath as NSIndexPath).row] as! NSDictionary
        cell.albumName.text = albumDetails["label"] as? String
        cell.albumGenre.text = (albumDetails["genre"]! as AnyObject).componentsJoined(by: "")
        cell.albumArtists.text = (albumDetails["artist"]! as AnyObject).componentsJoined(by: "")
        
        let thumbnail = albumDetails["thumbnail"] as! String

        if thumbnail != "" {
            cell.albumInitial.isHidden = true
            let url = URL(string: getThumbnailUrl(thumbnail))
            
            cell.albumImage.contentMode = .scaleAspectFit
            
            cell.albumImage.kf.setImage(with: url!)

        }else{
            cell.albumImage.isHidden = true
            cell.albumInitial.isHidden = false
            let randomColor = backgroundColors[Int(arc4random_uniform(UInt32(backgroundColors.count)))]
            
            let name = albumDetails["label"] as! String
            let index1 = name.characters.index(name.startIndex, offsetBy: 1)
            
            cell.albumInitial.text = name.substring(to: index1)
            cell.albumInitial.backgroundColor = UIColor(hex: randomColor)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func generateResponse(_ jsonData: AnyObject){
        let total = (jsonData["limits"] as! NSDictionary)["total"] as! Int
        
        if total != 0 {
            let albumDetails = jsonData["albums"] as! NSArray
            self.albumObjs = albumDetails
        }else {
            // Display No data found message
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAlbumDetails" {
            let destination = segue.destination as! AlbumDetailsTableViewController
            if let albumIndex = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row {
                destination.albumId = (self.albumObjs[albumIndex] as! NSDictionary)["albumid"] as! Int
                destination.albumName = (self.albumObjs[albumIndex] as! NSDictionary)["label"] as! String
            }
        }
    }

}
