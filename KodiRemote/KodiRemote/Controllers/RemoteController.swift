//
//  RemoteController.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 18/12/15.
//  Copyright © 2015 Quixom Technology. All rights reserved.
//

import Foundation
import Kingfisher
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}



class RemoteController: ViewController {
    
    @IBOutlet var itemName: UILabel!
    @IBOutlet var otherDetails: UILabel!
    @IBOutlet var activePlayerImage: UIImageView!
    
    @IBOutlet var nothingPlaying: UILabel!
    @IBOutlet var play: UIButton!
    @IBOutlet var pause: UIButton!
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var totalTimeLabel: UILabel!
    @IBOutlet var seekBar: UISlider!
    var playerId = 0
    var player_repeat = "off"
    var shuffle = false
    
    @IBOutlet var musicButtonLeadingSpace: NSLayoutConstraint!
    @IBOutlet var videoButtonTrailingSpace: NSLayoutConstraint!
    
    @IBOutlet var repeatButtonLeadingSpace: NSLayoutConstraint!
    @IBOutlet var volumUpLeadingSpace: NSLayoutConstraint!
    
    @IBOutlet var playerRepeat: UIButton!
    @IBOutlet var playerShuffle: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var rc: RemoteCalls!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.view.viewWithTag(2)?.isHidden = true
        
        self.backgroundImage.layer.opacity = 0.1
        self.view.viewWithTag(2)?.layer.opacity = 0.9
        self.view.viewWithTag(1)?.layer.opacity = 0.9
        
        let previous_ip = UserDefaults.standard
        if let ip = previous_ip.string(forKey: "ip"){
            global_ipaddress = ip
        }
        
        if let port = previous_ip.string(forKey: "port"){
            global_port = port
        }
        
        if global_ipaddress == "" {
            let discovery = self.storyboard?.instantiateViewController(withIdentifier: "DiscoveryView") as! DiscoveryTableViewController
            self.navigationController?.pushViewController(discovery, animated: true)
        }
        
        if global_ipaddress != "" {
            rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
            self.syncPlayer()
        }
    }

    func syncPlayer(){
        
        self.rc.jsonRpcCall("Player.GetActivePlayers"){(response: AnyObject?) in
            
            if response!.count == 0 {
                DispatchQueue.main.async(execute: {
                    self.view.viewWithTag(2)?.isHidden = true
                    self.nothingPlaying.isHidden = false
                    self.backgroundImage.isHidden = true
                })
                
                return
            }
            
            DispatchQueue.main.async(execute: {
                self.view.viewWithTag(2)?.isHidden = false
                self.nothingPlaying.isHidden = true
                self.backgroundImage.isHidden = false
            })
            
            let response = (response as! NSArray)[0] as? NSDictionary
            self.playerId = response!["playerid"] as! Int
            
            self.rc.jsonRpcCall("Player.GetProperties", params: "{\"playerid\":\(self.playerId),\"properties\":[\"percentage\",\"time\",\"totaltime\", \"repeat\",\"shuffled\",\"speed\",\"subtitleenabled\"]}"){(response: AnyObject?) in
                
                DispatchQueue.main.async(execute: {
                    
                    let response = response as? NSDictionary
                    self.shuffle = response!["shuffled"] as! Bool
                    self.player_repeat = response!["repeat"] as! String
                    
                    let repeateImage = self.player_repeat == "off" ? "Repeat": "RepeatSelected"
                    self.playerRepeat.imageView?.image = UIImage(named: repeateImage)
                    
                    let suffleImage = self.shuffle == true ? "shuffleSelected" : "shuffle"
                    self.playerShuffle.imageView?.image = UIImage(named: suffleImage)
                    
                    if response!["speed"] as! Int == 0 {
                        self.play.isHidden = false
                        self.pause.isHidden = true
                    }else{
                        self.play.isHidden = true
                        self.pause.isHidden = false
                    }
                    
                    self.timeLabel.text = self.toMinutes(response!["time"] as! NSDictionary)
                    self.totalTimeLabel.text = self.toMinutes(response!["totaltime"] as! NSDictionary)
                    
                    self.seekBar.value = (response!["percentage"] as! Float) / 100
                })
                
                self.rc.jsonRpcCall("Player.GetItem", params: "{\"playerid\":\(self.playerId),\"properties\":[\"title\",\"artist\",\"thumbnail\", \"fanart\", \"album\",\"year\"]}"){(response: AnyObject?) in
                    
                    DispatchQueue.main.async(execute: {
                        let response = response as? NSDictionary
                        self.generateResponse(response!)
                    });
                }
            }
        }
        
        // 1 second trigger Time
        let triggerTime = Int64(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
            self.syncPlayer()
        })
    }
    
    @IBAction func sliderTouchUp(_ sender: UISlider) {
        // RPC call for seek
        let value = Int(sender.value * 100)
        self.seekBar.value = sender.value
        rc.jsonRpcCall("Player.Seek", params: "{\"playerid\":\(self.playerId), \"value\":\(value)}"){(response: AnyObject?) in
        }
    }
    
    func generateResponse(_ jsonData: AnyObject){
        for(key, value) in jsonData["item"] as! NSDictionary{
            if key as! String == "label" {
                self.itemName.text = value as? String
            }
            
            if key as! String == "artist" {
                self.otherDetails.text = ""
                if (value as AnyObject).count != 0 {
                    self.otherDetails.text = (value as! NSArray)[0] as? String
                }
            }
            
            if key as! String == "thumbnail" {
                
                self.activePlayerImage.contentMode = .scaleAspectFit
                
                let url = URL(string: getThumbnailUrl(value as! String))
                self.activePlayerImage.kf.setImage(with: url!)
            }
            
            if key as! String == "fanart" {
                
                self.backgroundImage.contentMode = .scaleAspectFill
                
                let url = URL(string: getThumbnailUrl(value as! String))
                self.backgroundImage.kf.setImage(with: url!)
            }
        }
    }
    
    func toMinutes(_ temps: NSDictionary ) -> String {
        var seconds = String(temps["seconds"] as! Int)
        var minutes = String(temps["minutes"] as! Int)
        var hours = String(temps["hours"] as! Int)
        
        if (Int(seconds) < 10) {
            seconds = "0" + seconds
        }
        if (Int(minutes) < 10) {
            minutes = "0" + minutes
        }
        if (Int(hours) < 10) {
            hours = "0" + hours
        }
        
        var time = minutes + ":" + seconds
        
        if Int(hours) != 0 {
            time = hours + ":" + minutes + ":" + seconds
        }
        
        return time
    }
    
    @IBAction func previousButton(_ sender: AnyObject) {
        rc.jsonRpcCall("Input.ExecuteAction", params: "{\"action\":\"skipprevious\"}"){(response: AnyObject?) in
        }
    }
    
    @IBAction func fastRewindButton(_ sender: AnyObject) {
        rc.jsonRpcCall("Input.ExecuteAction", params: "{\"action\":\"stepback\"}"){(response: AnyObject?) in
        }
    }
    
    
    @IBAction func stopButton(_ sender: AnyObject) {
        rc.jsonRpcCall("Input.ExecuteAction", params: "{\"action\":\"stop\"}"){(response: AnyObject?) in
        }
    }
    
    @IBAction func playButton(_ sender: AnyObject) {
        rc.jsonRpcCall("Input.ExecuteAction", params: "{\"action\":\"play\"}"){(response: AnyObject?) in
        }
    }
    
    @IBAction func pauseButton(_ sender: AnyObject) {
        rc.jsonRpcCall("Input.ExecuteAction", params: "{\"action\":\"pause\"}"){(response: AnyObject?) in
        }
    }
    
    @IBAction func fastForwardButton(_ sender: AnyObject) {
        rc.jsonRpcCall("Input.ExecuteAction", params: "{\"action\":\"stepforward\"}"){(response: AnyObject?) in
        }
    }
    
    @IBAction func nextButton(_ sender: AnyObject) {
        rc.jsonRpcCall("Input.ExecuteAction", params: "{\"action\":\"skipnext\"}"){(response: AnyObject?) in
        }
    }
    
    @IBAction func leftButton(_ sender: AnyObject) {
        rc.jsonRpcCall("Input.Left"){(response: AnyObject?) in
        }
    }
    
    @IBAction func rightButton(_ sender: AnyObject) {
        rc.jsonRpcCall("Input.Right"){(response: AnyObject?) in
        }
    }
    
    @IBAction func downButton(_ sender: AnyObject) {
        rc.jsonRpcCall("Input.Down"){(response: AnyObject?) in
        }
    }
    
    @IBAction func upButton(_ sender: AnyObject) {
        rc.jsonRpcCall("Input.Up"){(response: AnyObject?) in
        }
    }
    
    @IBAction func okButton(_ sender: AnyObject) {
        rc.jsonRpcCall("Input.Select"){(response: AnyObject?) in
        }
    }
    
    @IBAction func homeButton(_ sender: AnyObject) {
        rc.jsonRpcCall("Input.Home"){(response: AnyObject?) in
        }
    }
    
    @IBAction func backButton(_ sender: AnyObject) {
        rc.jsonRpcCall("Input.Back"){(response: AnyObject?) in
        }
    }
    
    @IBAction func tvButton(_ sender: AnyObject) {
        rc.jsonRpcCall("GUI.ActivateWindow", params: "{\"window\": \"videos\",\"parameters\":[\"TvShowTitles\"]}"){(response: AnyObject?) in
        }
    }
    
    @IBAction func moviesButton(_ sender: AnyObject) {
        rc.jsonRpcCall("GUI.ActivateWindow", params: "{\"window\": \"video\",\"parameters\":[\"MovieTitles\"]}"){(response: AnyObject?) in
        }
    }
    
    @IBAction func musicButton(_ sender: AnyObject) {
        rc.jsonRpcCall("GUI.ActivateWindow", params: "{\"window\": \"music\"}"){(response: AnyObject?) in
        }
    }
    
    @IBAction func pictureButton(_ sender: AnyObject) {
        rc.jsonRpcCall("GUI.ActivateWindow", params: "{\"window\": \"pictures\"}"){(response: AnyObject?) in
        }
    }
    
    @IBAction func volumeDownButton(_ sender: AnyObject) {
        rc.jsonRpcCall("Input.ExecuteAction", params: "{\"action\":\"volumedown\"}"){(response: AnyObject?) in
        }
    }
    
    @IBAction func muteButton(_ sender: AnyObject) {
        rc.jsonRpcCall("Input.ExecuteAction", params: "{\"action\":\"mute\"}"){(response: AnyObject?) in
        }
    }
    
    @IBAction func volumeUpButton(_ sender: AnyObject) {
        rc.jsonRpcCall("Input.ExecuteAction", params: "{\"action\":\"volumeup\"}"){(response: AnyObject?) in
        }
    }
    
    @IBAction func repeatButton(_ sender: AnyObject) {
        let r = self.player_repeat == "off" ? "all" : "off"
        rc.jsonRpcCall("Player.SetRepeat", params: "{\"playerid\":\(self.playerId), \"repeat\":\"\(r)\"}"){(response: AnyObject?) in
        }
    }
    
    @IBAction func shuffleButton(_ sender: AnyObject) {
        let s = self.shuffle == true ? "false": "true"
        rc.jsonRpcCall("Player.SetShuffle", params: "{\"playerid\":\(self.playerId), \"shuffle\":\(s)}"){(response: AnyObject?) in
        }
    }
    
    @IBAction func osdButton(_ sender: AnyObject) {
        rc.jsonRpcCall("Input.ShowOSD"){(response: AnyObject?) in
        }
    }
    
    @IBAction func contextButton(_ sender: AnyObject) {
        rc.jsonRpcCall("Input.ContextMenu"){(response: AnyObject?) in
        }
    }
    
    @IBAction func infoButton(_ sender: AnyObject) {
        rc.jsonRpcCall("Input.Info"){(response: AnyObject?) in
        }
    }
}
