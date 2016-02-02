//
//  RemoteController.swift
//  KodiRemote
//
//  Created by Quixom Technology on 18/12/15.
//  Copyright © 2015 Quixom Technology. All rights reserved.
//

import Foundation


class RemoteController: ViewController {
    
    @IBOutlet var itemName: UILabel!
    @IBOutlet var otherDetails: UILabel!
    @IBOutlet var activePlayerImage: UIImageView!
    
    @IBOutlet var backward: UIButton!
    @IBOutlet var stop: UIButton!
    @IBOutlet var play: UIButton!
    @IBOutlet var pause: UIButton!
    @IBOutlet var forward: UIButton!
    var imageCache = [String:UIImage]()
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var totalTimeLabel: UILabel!
    @IBOutlet var progressBar: UIProgressView!
    
	
	var rc: RemoteCalls!
	
	override func viewDidAppear(animated: Bool) {
        
        self.view.viewWithTag(2)?.hidden = true
        
        if global_ipaddress == "" {
            let discovery = self.storyboard?.instantiateViewControllerWithIdentifier("DiscoveryView") as! DiscoveryTableViewController
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
                dispatch_async(dispatch_get_main_queue(), {
                    self.view.viewWithTag(2)?.hidden = true
                })
                
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.view.viewWithTag(2)?.hidden = false
            })
            
            let response = response![0] as? NSDictionary
            let playerId = response!["playerid"] as! Int
            
            self.rc.jsonRpcCall("Player.GetProperties", params: "{\"playerid\":\(playerId),\"properties\":[\"percentage\",\"time\",\"totaltime\", \"repeat\",\"shuffled\",\"speed\",\"subtitleenabled\"]}"){(response: AnyObject?) in

                dispatch_async(dispatch_get_main_queue(), {

                    let response = response as? NSDictionary

                    if response!["speed"] as! Int == 0 {
                        self.play.hidden = false
                        self.pause.hidden = true
                    }else{
                        self.play.hidden = true
                        self.pause.hidden = false
                    }
                    
                    self.timeLabel.text = self.toMinutes(response!["time"] as! NSDictionary)
                    self.totalTimeLabel.text = self.toMinutes(response!["totaltime"] as! NSDictionary)
                    
                    self.progressBar.progress = (response!["percentage"] as! Float) / 100
                })
                
                self.rc.jsonRpcCall("Player.GetItem", params: "{\"playerid\":\(playerId),\"properties\":[\"title\",\"artist\",\"thumbnail\", \"album\",\"year\"]}"){(response: AnyObject?) in
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        let response = response as? NSDictionary
                        self.generateResponse(response!)
                    });
                }
            }
        }

        // 1 second trigger Time
        let triggerTime = Int64(NSEC_PER_SEC)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            self.syncPlayer()
        })
    }
    
    func generateResponse(jsonData: AnyObject){
        for(key, value) in jsonData["item"] as! NSDictionary{
            if key as! String == "label" {
                self.itemName.text = value as? String
            }
            
            if key as! String == "artist" {
                self.otherDetails.text = value[0] as? String
            }
            
            if key as! String == "thumbnail" {

                self.activePlayerImage.contentMode = .ScaleAspectFit
                
                let url = NSURL(string: "http://" + global_ipaddress + ":" + global_port + "/image/" + (value as! String).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!)
                if let img = self.imageCache[(url?.absoluteString)!]{
                    self.activePlayerImage.image = img
                }else{
                    self.downloadImage(url!, imageURL: self.activePlayerImage)
                }
            }
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
    
    func toMinutes(temps: NSDictionary ) -> String {
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
    
    @IBAction func backwardButton(sender: AnyObject) {
        rc.jsonRpcCall("Input.ExecuteAction", params: "{\"action\":\"skipprevious\"}"){(response: AnyObject?) in
        }
    }
    
    @IBAction func stopButton(sender: AnyObject) {
        rc.jsonRpcCall("Input.ExecuteAction", params: "{\"action\":\"stop\"}"){(response: AnyObject?) in
        }
    }
    
    @IBAction func playButton(sender: AnyObject) {
        rc.jsonRpcCall("Input.ExecuteAction", params: "{\"action\":\"play\"}"){(response: AnyObject?) in
        }
    }
    
    @IBAction func pauseButton(sender: AnyObject) {
        rc.jsonRpcCall("Input.ExecuteAction", params: "{\"action\":\"pause\"}"){(response: AnyObject?) in
        }
    }
    
    @IBAction func forwardButton(sender: AnyObject) {
        rc.jsonRpcCall("Input.ExecuteAction", params: "{\"action\":\"skipnext\"}"){(response: AnyObject?) in
        }
    }
		
	@IBAction func leftButton(sender: AnyObject) {
        rc.jsonRpcCall("Input.Left"){(response: AnyObject?) in
        }
	}
	
	@IBAction func rightButton(sender: AnyObject) {
        rc.jsonRpcCall("Input.Right"){(response: AnyObject?) in
        }
	}
	
	@IBAction func downButton(sender: AnyObject) {
        rc.jsonRpcCall("Input.Down"){(response: AnyObject?) in
        }
	}
	
	@IBAction func upButton(sender: AnyObject) {
        rc.jsonRpcCall("Input.Up"){(response: AnyObject?) in
        }
	}
	
	@IBAction func okButton(sender: AnyObject) {
        rc.jsonRpcCall("Input.Select"){(response: AnyObject?) in
        }
	}
	
	@IBAction func homeButton(sender: AnyObject) {
        rc.jsonRpcCall("Input.Home"){(response: AnyObject?) in
        }
	}
	
	@IBAction func backButton(sender: AnyObject) {
        rc.jsonRpcCall("Input.Back"){(response: AnyObject?) in
        }
	}
	
	@IBAction func videoButton(sender: AnyObject) {
        rc.jsonRpcCall("GUI.ActivateWindow", params: "{\"window\": \"videos\"}"){(response: AnyObject?) in
        }
	}
	
	@IBAction func moviesButton(sender: AnyObject) {
        rc.jsonRpcCall("GUI.ActivateWindow", params: "{\"window\": \"video\"}"){(response: AnyObject?) in
        }
	}
	
	@IBAction func musicButton(sender: AnyObject) {
        rc.jsonRpcCall("GUI.ActivateWindow", params: "{\"window\": \"music\"}"){(response: AnyObject?) in
        }
	}
	
	@IBAction func pictureButton(sender: AnyObject) {
        rc.jsonRpcCall("GUI.ActivateWindow", params: "{\"window\": \"pictures\"}"){(response: AnyObject?) in
        }
	}
	
}