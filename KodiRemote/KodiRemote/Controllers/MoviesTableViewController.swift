//
//  MoviesTableViewController.swift
//  KodiRemote
//
//  Created by Quixom Technology on 29/12/15.
//  Copyright © 2015 Quixom Technology. All rights reserved.
//

import Foundation

class MoviesTableViewController: BaseTableViewController {

    var movieImages = [String]()
    var movieNames = [String]()
    var movieGenres = [String]()
    var movieTime = [String]()
    var movieYear = [String]()
    var movieFile = [String]()
    var imageCache = [String:UIImage]()
    
    var rc: RemoteCalls!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        // TODO: use shared preference to get ip address and port.
        self.rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        self.rc.jsonRpcCall("VideoLibrary.GetMovies", params: "{\"properties\":[\"genre\",\"year\",\"thumbnail\",\"runtime\", \"file\"]}"){(response: AnyObject?) in
            self.generateResponse(response as! NSDictionary)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movieNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MoviesTableViewCell", forIndexPath: indexPath) as! MoviesTableViewCell
        
        let row = indexPath.row
        cell.movieLabel.text = self.movieNames[row]
        cell.genreLabel.text = self.movieGenres[row]
        cell.timeLabel.text = self.movieTime[row]
        cell.yearLabel.text = self.movieYear[row]
        
        let url = NSURL(string: self.movieImages[row])
        
        cell.movieImage.contentMode = .ScaleAspectFit
        
        if let img = self.imageCache[self.movieImages[row]]{
            cell.movieImage.image = img
        }else{
            self.downloadImage(url!, imageURL: cell.movieImage)
        }
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0.0, cell.frame.height - 1, cell.frame.width, 0.5)
        bottomLine.backgroundColor = UIColor.grayColor().CGColor
        cell.layer.addSublayer(bottomLine)
        cell.clipsToBounds = true
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.rc.jsonRpcCall("Player.Open", params: "{\"item\":{\"file\":\"\(self.movieFile[indexPath.row])\"}}"){ (response: AnyObject?) in
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

    func generateResponse(jsonData: AnyObject){
        let total = jsonData["limits"]!!["total"] as! Int
        
        if total != 0 {
            let moviesDetails = jsonData["movies"] as! NSArray
            
            for item in moviesDetails{
                let obj = item as! NSDictionary
                for (key, value) in obj {
                    if key as! String == "label" {
                        self.movieNames.append(value as! String)
                    }
                    
                    if key as! String == "file" {
                        var file_name = value as! String
                        if file_name.hasPrefix("http") || file_name.hasPrefix("plugin"){
                            self.movieFile.append(file_name)
                        }else{
                            file_name = file_name.stringByReplacingOccurrencesOfString("\\", withString: "/")
                            self.movieFile.append(file_name)
                        }
                    }
                    
                    if key as! String == "genre"{
                        self.movieGenres.append(value.componentsJoinedByString(""))
                    }
                    
                    if key as! String == "runtime"{
                        let runtime = value as! Int / 60
                        self.movieTime.append(String(runtime)+" min")
                    }
                    if key as! String == "year"{
                        self.movieYear.append(String(value))
                    }
                    
                    if key as! String == "thumbnail"{
                        var thumbnail = value as! String
                        thumbnail = thumbnail.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
                        self.movieImages.append("http://" + global_ipaddress + ":" + global_port + "/image/" + thumbnail)
                    }
                }
            }
        }else {
            // Display No data found message
        }
    }

}
