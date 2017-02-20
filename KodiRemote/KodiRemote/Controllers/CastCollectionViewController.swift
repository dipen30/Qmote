//
//  CastCollectionViewController.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 19/08/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

private let reuseIdentifier = "CastCell"

class CastCollectionViewController: UICollectionViewController {
    
    var castDetailObjs = NSArray()
    
    var rc: RemoteCalls!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        var params = ""
        var method = ""
        if movie_id != 0{
            params = "\"movieid\":\(movie_id),"
            method = "VideoLibrary.GetMovieDetails"
        }else{
            params = "\"tvshowid\":\(tvshow_id),"
            method = "VideoLibrary.GetTVShowDetails"
        }
        
        rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        rc.jsonRpcCall(method, params: "{\(params)\"properties\":[\"cast\"]}"){ (response: AnyObject?) in
            
            self.generateResponse(response as! NSDictionary)
            
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.castDetailObjs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CastCollectionViewCell
        
        let castDetails = self.castDetailObjs[(indexPath as NSIndexPath).row] as! NSDictionary
        
        cell.castName.text = castDetails["name"] as? String
        cell.castName.layer.opacity = 0.9
        cell.castName.layer.borderWidth = 0.0
        
        cell.castRole.text = castDetails["role"] as? String
        cell.castRole.layer.opacity = 0.9
        cell.castRole.layer.borderWidth = 0.0
        
        if let val = castDetails["thumbnail"] {
            cell.castInitial.isHidden = true
            let url = URL(string: getThumbnailUrl((val as? String)!))
            cell.castImage.kf.setImage(with: url!)
        }else{
            cell.castInitial.isHidden = false
            let randomColor = backgroundColors[Int(arc4random_uniform(UInt32(backgroundColors.count)))]
            
            let name = castDetails["name"] as! String
            let index1 = name.characters.index(name.startIndex, offsetBy: 1)
            
            cell.castInitial.text = name.substring(to: index1)
            cell.castInitial.backgroundColor = UIColor(hex: randomColor)
        }
        
        return cell
    }
    
    func generateResponse(_ jsonData: AnyObject){
        
        var castDetails = NSArray()
        if let val = jsonData["moviedetails"]! {
            castDetails = (val as! NSDictionary)["cast"] as! NSArray
        }else if let val = jsonData["tvshowdetails"]! {
            castDetails = (val as! NSDictionary)["cast"] as! NSArray
        }
        
        self.castDetailObjs = castDetails
    }
    
}
