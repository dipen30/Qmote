//
//  TvShowDetailsController.swift
//  KodiRemote
//
//  Created by Quixom Technology on 23/02/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class TvShowDetailsController: UIViewController {
    
    @IBOutlet var tvShowArtImage: UIImageView!
    @IBOutlet var tvShowImage: UIImageView!
    @IBOutlet var tvShowName: UILabel!
    @IBOutlet var tvShowEpisodes: UILabel!
    @IBOutlet var tvShowPremiered: UILabel!
    @IBOutlet var tvShowGenre: UILabel!
    @IBOutlet var tvShowRatings: UILabel!
    @IBOutlet var tvShowPlot: UITextView!
    
    var tvshowid = Int()
    
    var rc: RemoteCalls!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidLoad()
        
        // TODO: use shared preference to get ip address and port.
        self.rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        self.rc.jsonRpcCall("VideoLibrary.GetTVShowDetails", params: "{\"tvshowid\":\(tvshowid),\"properties\":[\"art\",\"title\",\"thumbnail\",\"episode\",\"premiered\",\"watchedepisodes\",\"genre\",\"plot\",\"cast\",\"rating\",\"studio\"]}"){(response: AnyObject?) in

            dispatch_async(dispatch_get_main_queue()) {
                self.generateResponse(response as! NSDictionary)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tvShowName.text = ""
        self.tvShowEpisodes.text = ""
        self.tvShowPremiered.text = ""
        self.tvShowGenre.text = ""
        self.tvShowRatings.text = ""
        
        self.tvShowPlot.text = ""
        
    }
    
    func generateResponse(jsonData: AnyObject){

        let tvShowDetails = jsonData["tvshowdetails"] as! NSDictionary
        let episodes = String(tvShowDetails["episode"]!) + " Episodes | " + String(tvShowDetails["watchedepisodes"]!) + " watchedepisodes"

        self.tvShowName.text = String(tvShowDetails["label"]!)
        self.tvShowEpisodes.text = episodes
        self.tvShowPremiered.text = "Premiered: " + String(tvShowDetails["premiered"]!) + " | " + String(tvShowDetails["studio"]!.componentsJoinedByString(","))
        self.tvShowGenre.text = String(tvShowDetails["genre"]!.componentsJoinedByString(","))
        self.tvShowRatings.text = String(tvShowDetails["rating"]!) + "/10"
        
        self.tvShowPlot.text = String(tvShowDetails["plot"]!)
        
        self.tvShowImage.contentMode = .ScaleAspectFit
        self.tvShowImage.layer.zPosition = 1
        var thumbnail = String(tvShowDetails["thumbnail"]!)
        if thumbnail != "" {
            thumbnail = thumbnail.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
            let url = NSURL(string: "http://" + global_ipaddress + ":" + global_port + "/image/" + thumbnail)
            
            self.downloadImage(url!, imageURL: self.tvShowImage)
        }
        
        self.tvShowArtImage.contentMode = .ScaleAspectFill
        let art = tvShowDetails["art"]!
        if art.count != 0 {
            var fanart = art["fanart"] as! String
            if fanart != "" {
                fanart = fanart.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
                let url = NSURL(string: "http://" + global_ipaddress + ":" + global_port + "/image/" + fanart)
                
                self.downloadImage(url!, imageURL: self.tvShowArtImage)
            }
        }
    }
    
    func downloadImage(url: NSURL, imageURL: UIImageView){
        getImageDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                let image = UIImage(data: data)
                imageURL.image = image
            }
        }
    }
}