//
//  RemoteCalls.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 18/12/15.
//  Copyright © 2015 Quixom Technology. All rights reserved.
//

import Foundation


class RemoteCalls: NSObject {
    
    var ipaddress: String
    var port: String
    
    init(ipaddress: String, port: String){
        self.ipaddress = ipaddress
        self.port = port
    }
    
    func jsonRpcCall(_ method: String, params: String = "{}", callback: @escaping (AnyObject?) -> Void){
        
        let base_url = "http://" + self.ipaddress + ":" + self.port + "/jsonrpc"
        var urlComponents = URLComponents(string: base_url)!
        
        urlComponents.queryItems = [
            URLQueryItem(name: "request", value: "{\"jsonrpc\":\"2.0\",\"method\":\"" + method + "\",\"params\": " + params + ",\"id\": 1}"),
        ]
        
        let urlRequest = URLRequest(url: urlComponents.url!)
//        print(urlRequest)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            // do stuff with response, data & error here
            
            if data != nil {
                do {
                    let jsonDict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? NSDictionary
                    if let jsonDict = jsonDict {
                        // work with dictionary here
                        let jsonData = jsonDict["result"]
                        callback(jsonData as AnyObject?)
                    } else {
                        // more error handling
                    }
                } catch let error as NSError {
                    // error handling
                    print(error)
                }
            }
        })
        
        task.resume()
    }
}
