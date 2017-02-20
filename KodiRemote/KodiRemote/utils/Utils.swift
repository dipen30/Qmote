//
//  Utils.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 05/01/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import Foundation
import GCDWebServer
import MobileCoreServices

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex:Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
}

func getThumbnailUrl(_ thumbnail: String) -> String{
    var url = ""
    url = thumbnail.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    url = "http://" + global_ipaddress + ":" + global_port + "/image/" + url
    
    return url
}

func startServer(){
    
    if webServer == nil {
        webServer = GCDWebServer()
        var dir = NSHomeDirectory()
        dir = dir + "/media/"
        
        if !FileManager().fileExists(atPath: dir) {
            do{
                try FileManager().createDirectory(atPath: dir, withIntermediateDirectories: false, attributes: nil)
            } catch let err as NSError{
                print(err)
            }
        }
        
        webServer.addGETHandler(forBasePath: "/", directoryPath: dir, indexFilename: nil, cacheAge: 3600, allowRangeRequests: true)
        
//        webServer.addDefaultHandlerForMethod("GET", requestClass: GCDWebServerRequest.self, asyncProcessBlock: { (request, completionBlock) in
//            
//            let path = String(request.query["file_path"]!)
//            let response = GCDWebServerFileResponse(file: path, byteRange: request.byteRange)
//            completionBlock(response)
//        })
        
        webServer.start(withPort: 8081, bonjourName: nil)
    }
}

func remove_content(){
    
    let filemanager = FileManager.default

//    let dirPath = NSSearchPathForDirectoriesInDomains(. , .UserDomainMask, true)[0]
    let dirPath = NSHomeDirectory() + "/media/"
    let directoryContents: NSArray = try! filemanager.contentsOfDirectory(atPath: dirPath) as NSArray
    
    if directoryContents.count > 0 {
        for path in directoryContents {
            let fullPath = dirPath + ("/"+(path as! String))
            
            do {
                try filemanager.removeItem(atPath: fullPath)
            } catch let err as NSError {
                print(err)
            }
        }
    }
}

func getLocalFilePath(_ destdirname:String, filename: String) -> URL{
    
    let dir = NSHomeDirectory()
    var destpath = dir + "/\(destdirname)/"
    
    destpath = destpath + filename

    return URL(fileURLWithPath: destpath)
}

func is_file_exists(_ destdirname:String, filename: String) -> Bool{
    
    let dir = NSHomeDirectory()
    var destpath = dir + "/\(destdirname)/"
    
    destpath = destpath + filename
    
    let fileManager = FileManager()
    if fileManager.fileExists(atPath: destpath){
        return true
    }
    
    return false
}

func MIMEType(_ fileExtension: String) -> String? {
    if !fileExtension.isEmpty {
        let UTIRef = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)
        let UTI = UTIRef!.takeUnretainedValue()
        UTIRef!.release()
        
        let MIMETypeRef = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType)
        if MIMETypeRef != nil
        {
            let MIMEType = MIMETypeRef!.takeUnretainedValue()
            MIMETypeRef!.release()
            return MIMEType as String
        }
    }
    return nil
}

func md5(string: String) -> String {
    var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
    if let data = string.data(using: String.Encoding.utf8) {
        CC_MD5((data as NSData).bytes, CC_LONG(data.count), &digest)
    }
    
    var digestHex = ""
    for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
        digestHex += String(format: "%02x", digest[index])
    }
    
    return digestHex
}
