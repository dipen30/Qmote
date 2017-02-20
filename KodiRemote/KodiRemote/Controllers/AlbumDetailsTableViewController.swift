//
//  AlbumDetailsTableViewController.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 06/01/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class AlbumDetailsTableViewController: UITableViewController {
    
    var albumId = Int()
    var albumName = String()
    
    var albumDetailObjs = NSArray()
    
    var rc: RemoteCalls!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        var params = ""
        if self.albumId != 0{
            params = "\"filter\":{\"albumid\":\(self.albumId)},"
            self.navigationItem.title = albumName
        }
        
        rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        rc.jsonRpcCall("AudioLibrary.GetSongs", params: "{\(params)\"properties\":[\"thumbnail\",\"genre\",\"album\",\"albumartist\"]}"){ (response: AnyObject?) in
            self.generateResponse(response as! NSDictionary)
            
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
        return self.albumDetailObjs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumDetailsTableViewCell", for: indexPath) as! AlbumDetailsTableViewCell
        
        let albumDetails = self.albumDetailObjs[(indexPath as NSIndexPath).row] as! NSDictionary
        cell.songName.text = albumDetails["label"] as? String
        
        cell.albumArtists.text = (albumDetails["albumartist"]! as AnyObject).componentsJoined(by: ",")
        let album = albumDetails["album"] as! String
        let genre = (albumDetails["genre"]! as AnyObject).componentsJoined(by: ",")
        
        cell.otherDetails.text = album + " | " + genre
        
        let thumbnail = albumDetails["thumbnail"] as! String
        
        if thumbnail != "" {
            cell.songInitial.isHidden = true
            cell.songImage.isHidden = false
            
            let url = URL(string: getThumbnailUrl(thumbnail))
            
            cell.songImage.contentMode = .scaleAspectFit
            cell.songImage.kf.setImage(with: url!)
            
        }else{
            cell.songInitial.isHidden = false
            cell.songImage.isHidden = true
            let randomColor = backgroundColors[Int(arc4random_uniform(UInt32(backgroundColors.count)))]
            
            let name = albumDetails["label"] as! String
            let index1 = name.characters.index(name.startIndex, offsetBy: 1)
            
            cell.songInitial.text = name.substring(to: index1)
            cell.songInitial.backgroundColor = UIColor(hex: randomColor)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.rc.jsonRpcCall("Playlist.clear", params: "{\"playlistid\":0}"){ (response: AnyObject?) in
            if self.albumId != 0 {
                self.rc.jsonRpcCall("Playlist.Add", params: "{\"playlistid\":0, \"item\":{\"albumid\":\(self.albumId)}}"){ (response: AnyObject?) in
                    self.rc.jsonRpcCall("Player.Open", params: "{\"item\":{\"playlistid\":0, \"position\": \((indexPath as NSIndexPath).row)}}"){ (response: AnyObject?) in
                    }
                }
            }else{
                let song = self.albumDetailObjs[(indexPath as NSIndexPath).row] as! NSDictionary
                self.rc.jsonRpcCall("Playlist.Add", params: "{\"playlistid\":0, \"item\":{\"songid\":\(song["songid"] as! Int)}}"){ (response: AnyObject?) in
                    self.rc.jsonRpcCall("Player.Open", params: "{\"item\":{\"playlistid\":0}}"){ (response: AnyObject?) in
                    }
                }
            }
        }
    }
    
    func generateResponse(_ jsonData: AnyObject){
        let total = (jsonData["limits"] as! NSDictionary)["total"] as! Int
        
        if total != 0 {
            let albumDetails = jsonData["songs"] as! NSArray
            
            self.albumDetailObjs = albumDetails
        }else {
            // Display No data found message
        }
    }
    
}
