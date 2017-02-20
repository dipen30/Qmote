//
//  TvShowDetailsController.swift
//  Kodi Remote 
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        
        self.rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        tvshow_id = tvshowid
        self.rc.jsonRpcCall("VideoLibrary.GetTVShowDetails", params: "{\"tvshowid\":\(tvshowid),\"properties\":[\"art\",\"title\",\"thumbnail\",\"episode\",\"premiered\",\"watchedepisodes\",\"genre\",\"plot\",\"cast\",\"rating\",\"studio\"]}"){(response: AnyObject?) in

            DispatchQueue.main.async {
                self.generateResponse(response as! NSDictionary)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tvShowName.text = ""
        self.tvShowEpisodes.text = ""
        self.tvShowPremiered.text = ""
        self.tvShowGenre.text = ""
        self.tvShowRatings.text = ""
        
        self.tvShowPlot.text = ""
        
    }
    
    deinit {
        tvshow_id = 0
    }
    
    func generateResponse(_ jsonData: AnyObject){

        let tvShowDetails = jsonData["tvshowdetails"] as! NSDictionary
        let episodes = String(describing: tvShowDetails["episode"]!) + " Episodes | " + String(describing: tvShowDetails["watchedepisodes"]!) + " watchedepisodes"

        self.tvShowName.text = String(describing: tvShowDetails["label"]!)
        self.tvShowEpisodes.text = episodes
        self.tvShowPremiered.text = "Premiered: " + String(describing: tvShowDetails["premiered"]!) + " | " + String((tvShowDetails["studio"]! as AnyObject).componentsJoined(by: ","))
        self.tvShowGenre.text = String((tvShowDetails["genre"]! as AnyObject).componentsJoined(by: ","))
        self.tvShowRatings.text = String(format: "%.1f", tvShowDetails["rating"]! as! Double) + "/10"
        
        self.tvShowPlot.text = String(describing: tvShowDetails["plot"]!)
        
        self.tvShowImage.contentMode = .scaleAspectFit
        self.tvShowImage.layer.zPosition = 1
        let thumbnail = String(describing: tvShowDetails["thumbnail"]!)
        if thumbnail != "" {
            let url = URL(string: getThumbnailUrl(thumbnail))
            
            self.tvShowImage.kf.setImage(with: url!)
        }
        
        self.tvShowArtImage.contentMode = .scaleAspectFill
        let art = tvShowDetails["art"] as! NSDictionary
        if (art as AnyObject).count != 0 {
            let fanart = art["fanart"] as! String
            if fanart != "" {
                let url = URL(string: getThumbnailUrl(fanart))
                
                self.tvShowArtImage.kf.setImage(with: url!)
            }
        }
    }
    
}
