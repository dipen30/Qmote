//
//  AddonTableViewController.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 01/01/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class AddonTableViewController: BaseTableViewController {

    var addonObjs = NSArray()
    
    var rc: RemoteCalls!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        rc.jsonRpcCall("Addons.GetAddons", params: "{\"properties\":[\"name\",\"summary\",\"thumbnail\"],\"type\":\"xbmc.python.pluginsource\"}"){(response: AnyObject?) in
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
        return self.addonObjs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddonsTableViewCell", for: indexPath) as! AddonTableViewCell
        
        let addonDetails = self.addonObjs[(indexPath as NSIndexPath).row] as! NSDictionary
        cell.addonLabel.text = addonDetails["name"] as? String
        cell.summary.text = addonDetails["summary"] as? String
        
        let thumbnail = addonDetails["thumbnail"] as! String
        
        if thumbnail != ""{
            cell.addonInitial.isHidden = true
            let url = URL(string: getThumbnailUrl(thumbnail))
        
            cell.addonImage.contentMode = .scaleAspectFit
            
            cell.addonImage.kf.setImage(with: url!)

        }else{
            cell.imageView?.isHidden = true
            let randomColor = backgroundColors[Int(arc4random_uniform(UInt32(backgroundColors.count)))]
            
            let name = addonDetails["name"] as! String
            let index1 = name.characters.index(name.startIndex, offsetBy: 1)
            
            cell.addonInitial.text = name.substring(to: index1)
            cell.addonInitial.backgroundColor = UIColor(hex: randomColor)
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // call jsonRPC call to display Details
        let addon = ( self.addonObjs[(indexPath as NSIndexPath).row] as! NSDictionary)
        rc.jsonRpcCall("Addons.ExecuteAddon", params: "{\"addonid\":\"\(addon["addonid"] as! String)\"}"){(response: AnyObject?) in
        }
    }
    
    func generateResponse(_ jsonData: AnyObject){
        let total = (jsonData["limits"] as! NSDictionary)["total"] as! Int
        
        if total != 0 {
            let addonDetails = jsonData["addons"] as! NSArray
            
            self.addonObjs = addonDetails
        }else {
            // Display No data found message
        }
    }
    
}
