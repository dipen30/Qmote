//
//  RemoteCalls.swift
//  KodiRemote
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
	
    func jsonRpcCall(method: String, params: String = "{}", callback: (NSDictionary?) -> Void){
		
		let base_url = "http://" + self.ipaddress + ":" + self.port + "/jsonrpc"
		let urlComponents = NSURLComponents(string: base_url)!
		
		urlComponents.queryItems = [
			NSURLQueryItem(name: "request", value: "{\"jsonrpc\":\"2.0\",\"method\":\"" + method + "\",\"params\": " + params + ",\"id\": 1}"),
		]
		
		let urlRequest = NSURLRequest(URL: urlComponents.URL!)
		
		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
		let session = NSURLSession(configuration: config)
		
		let task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data, response, error) in
			// do stuff with response, data & error here
            
            do {
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
                if let jsonDict = jsonDict {
                    // work with dictionary here
                    callback(jsonDict["result"] as? NSDictionary)
                } else {
                    // more error handling
                }
            } catch let error as NSError {
                // error handling
                print(error)
            }
		})
		
		task.resume()
	}
}