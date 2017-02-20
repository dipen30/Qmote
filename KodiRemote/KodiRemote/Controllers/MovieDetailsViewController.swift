//
//  MovieDetailsViewController.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 19/08/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    
    @IBOutlet var movieArtImage: UIImageView!
    @IBOutlet var movieImage: UIImageView!
    @IBOutlet var movieName: UILabel!
    @IBOutlet var movieTagline: UILabel!
    @IBOutlet var movieRuntime: UILabel!
    @IBOutlet var movieGenre: UILabel!
    @IBOutlet var movieRatings: UILabel!
    @IBOutlet var moviePlot: UITextView!
    @IBOutlet weak var movieDirectors: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playButtonTop: NSLayoutConstraint!
    @IBOutlet weak var downloadButton: UIButton!


    var url: URL!
    var videoTitle: String!
    var fileHash: String!
    
    var movieid = Int()
    var moviefile = String()

    var movieView: UIView!
    
    var rc: RemoteCalls!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        movie_id = movieid
        self.rc.jsonRpcCall("VideoLibrary.GetMovieDetails", params: "{\"movieid\":\(movieid),\"properties\":[\"genre\",\"year\",\"rating\",\"director\",\"trailer\",\"tagline\",\"plot\",\"imdbnumber\",\"runtime\",\"votes\",\"thumbnail\",\"art\"]}"){(response: AnyObject?) in
            
            DispatchQueue.main.async {
                self.generateResponse(response as! NSDictionary)
                self.playButton.isHidden = false
                self.downloadButton.isHidden = false
            }
        }
        
        self.moviefile = self.moviefile.replacingOccurrences(of: "\\", with: "/")

        self.rc.jsonRpcCall("Files.PrepareDownload", params: "{\"path\":\"\(self.moviefile)\"}"){ (response: AnyObject?) in
            let data = response as! NSDictionary
            let path = "/" + String(describing: (data["details"] as! NSDictionary)["path"]!)
            let host = "http://" + global_ipaddress + ":" + global_port
            self.url = URL(string: host + path)

            // if Same video is already in progress then do not allow user
            // to download the video
            self.fileHash = md5(string: self.url.lastPathComponent)
            if downloadQueue[self.fileHash] != nil{
                DispatchQueue.main.async {
                    self.downloadButton.isEnabled = false
                }
                downloadQueue[self.fileHash] = self.downloadButton
            }
            
            // change the color of download icon if file exists
            if is_file_exists("Videos", filename: self.url!.lastPathComponent){
                DispatchQueue.main.async {
                    self.downloadButton.tintColor = UIColor(red:0.01, green:0.66, blue:0.96, alpha:1.0)
                }
            }
        }
    }
    
    deinit {
        movie_id = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateViewBasedOnScreenSize()
        
        self.playButton.layer.cornerRadius = 0.5 * self.playButton.bounds.size.width
        self.playButton.layer.borderWidth = 2.0
        self.playButton.layer.borderColor = UIColor(red:0.00, green:0.80, blue:1.00, alpha:1.0).cgColor
        self.playButton.clipsToBounds = true
        
        self.movieName.text = ""
        self.movieTagline.text = ""
        self.movieRuntime.text = ""
        self.movieGenre.text = ""
        self.movieRatings.text = ""
        
        self.moviePlot.text = ""
        self.movieDirectors.text = ""
        
    }
    
    func updateViewBasedOnScreenSize(){
        // Updated constrains based on screen size
        let viewWidth = self.view.bounds.size.width
        if viewWidth < 350 {
            self.playButtonTop.constant = 135.0
        }else if viewWidth > 350 && viewWidth < 400 {
            self.playButtonTop.constant = 145.0
        }else if viewWidth > 400 {
            self.playButtonTop.constant = 160.0
        }
    }
    
    @IBAction func playMovie(_ sender: AnyObject) {
        self.rc.jsonRpcCall("Player.Open", params: "{\"item\":{\"movieid\":\(self.movieid)}}"){ (response: AnyObject?) in
        }
    }
    
    
    func generateResponse(_ jsonData: AnyObject){
        
        let movieDetails = jsonData["moviedetails"] as! NSDictionary
        
        self.movieName.text = String(describing: movieDetails["label"]!)
        self.videoTitle = String(describing: movieDetails["label"]!)
        self.movieTagline.text = String(describing: movieDetails["tagline"]!)
        self.movieRuntime.text = String((movieDetails["runtime"]! as! Int) / 60) + " min | " + String(describing: movieDetails["year"]!)
        self.movieGenre.text = String((movieDetails["genre"]! as AnyObject).componentsJoined(by: ", "))
        self.movieRatings.text = String(format: "%.1f", movieDetails["rating"]! as! Double) + "/10"
        
        self.moviePlot.text = String(describing: movieDetails["plot"]!)
        self.movieDirectors.text = "Directors: " + String((movieDetails["director"]! as AnyObject).componentsJoined(by: ", "))
        
        self.movieImage.contentMode = .scaleAspectFit
        self.movieImage.layer.zPosition = 1
        let thumbnail = String(describing: movieDetails["thumbnail"]!)
        if thumbnail != "" {
            let url = URL(string: getThumbnailUrl(thumbnail))
            
            self.movieImage.kf.setImage(with: url!)
        }
        
        self.movieArtImage.contentMode = .scaleAspectFill
        let art = movieDetails["art"] as! NSDictionary
        if (art as AnyObject).count != 0 {
            let fanart = art["fanart"] as! String
            if fanart != "" {
                let url = URL(string: getThumbnailUrl(fanart))
                
                self.movieArtImage.kf.setImage(with: url!)
            }
        }
    }
    
    @IBAction func downloadMovie(_ sender: AnyObject) {

        if is_file_exists("Videos", filename: self.url!.lastPathComponent){
            print("Play Video locally")
//            let videoUrl = getLocalFilePath("Videos", filename: self.url!.lastPathComponent!)
//            let playerVC = MobilePlayerViewController(contentURL: videoUrl)
//            playerVC.title = self.videoTitle
//            playerVC.activityItems = [videoUrl]
//            presentMoviePlayerViewControllerAnimated(playerVC)
        }else{
            if downloadQueue[self.fileHash] != nil{
                print("Downloading for this file is in progress")
            }else{
                downloadQueue.setValue(self.downloadButton, forKey: self.fileHash)

                Downloader(destdirname: "Videos").download(self.url!)
                self.downloadButton.isEnabled = false
            }
        }
    }
}
