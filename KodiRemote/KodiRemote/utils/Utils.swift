//
//  Utils.swift
//  KodiRemote
//
//  Created by Quixom Technology on 05/01/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import Foundation


func getImageDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
    NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
        completion(data: data, response: response, error: error)
        }.resume()
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