//
//  GenreTableViewController.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 05/01/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class GenreTableViewController: UITableViewController {

    var genreNames = [String]()
    var genreIds = [Int]()
    var genreInitials = [String]()
    var genreObjs = NSArray()
    
    var rc: RemoteCalls!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        rc.jsonRpcCall("AudioLibrary.GetGenres", params: "{\"properties\":[]}"){ (response: AnyObject?) in
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
        return self.genreObjs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenreTableViewCell", for: indexPath) as! GenreTableViewCell
        
        let genereDetails = self.genreObjs[(indexPath as NSIndexPath).row] as! NSDictionary
        cell.genreName.text = genereDetails["label"] as? String
        
        let randomColor = backgroundColors[Int(arc4random_uniform(UInt32(backgroundColors.count)))]
        
        let name = genereDetails["label"] as! String
        let index1 = name.characters.index(name.startIndex, offsetBy: 1)
        cell.genreInitial.text = name.substring(to: index1)
        cell.genreInitial.backgroundColor = UIColor(hex: randomColor)
        
        return cell
    }
    
    func generateResponse(_ jsonData: AnyObject){
        let total = (jsonData["limits"] as! NSDictionary)["total"] as! Int
        
        if total != 0 {
            let genreDetails = jsonData["genres"] as! NSArray
            
            self.genreObjs = genreDetails
            
            for item in genreDetails{
                let obj = item as! NSDictionary
                for (key, value) in obj {
                    if key as! String == "label" {
                        let name = value as! String
                        self.genreNames.append(name)
                        let index1 = name.characters.index(name.startIndex, offsetBy: 1)
                        self.genreInitials.append(name.substring(to: index1))
                    }
                    
                    if key as! String == "genreid"{
                        self.genreIds.append(value as! Int)
                    }
                }
            }
        }else {
            // Display No data found message
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAlbumsByGenre" {
            let destination = segue.destination as! AlbumsTableViewController
            if let albumIndex = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row {
                destination.artistId = self.genreIds[albumIndex]
                destination.artistName = self.genreNames[albumIndex]
            }
        }
    }
}
