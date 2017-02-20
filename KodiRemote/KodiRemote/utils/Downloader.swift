//
//  Downloader.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 05/09/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import Foundation


class Downloader : NSObject, URLSessionDownloadDelegate
{
    var progress: Float!
    var destpath: String
    var filename: String
    var button: UIButton!
    
    init(destdirname:String) {
        let dir = NSHomeDirectory()
        self.destpath = dir + "/\(destdirname)/"
        
        if !FileManager().fileExists(atPath: self.destpath) {
            do{
                try FileManager().createDirectory(atPath: self.destpath, withIntermediateDirectories: false, attributes: nil)
            } catch let err as NSError{
                print(err)
            }
        }
        
        self.filename = ""
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL){
        
        let fileManager = FileManager.default
        let fileURL = URL(fileURLWithPath: self.destpath)
        do {
            try fileManager.moveItem(at: location, to: fileURL)
        } catch let error as NSError {
            print("Error while moving downloaded file to destination path:\(error)")
        }
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                                 totalBytesWritten: Int64,
                                 totalBytesExpectedToWrite: Int64){
        //progressView.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
        progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        print("Progress : \(progress)")
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        
        //progressView.setProgress(0.0, animated: true)
        progress = 0.0
        
        if (error != nil) {
            print(error)
        }else{
            print("The task finished transferring data successfully")
            
            let file_hash = md5(string: self.filename)
            self.button = downloadQueue[file_hash] as! UIButton
            self.button.tintColor = UIColor(red:0.01, green:0.66, blue:0.96, alpha:1.0)
            self.button.isEnabled = true
            
            downloadQueue.removeObject(forKey: file_hash)
        }
    }
    
    //method to be called to download
    func download(_ url: URL)
    {
        self.filename = url.lastPathComponent
        self.destpath = self.destpath + self.filename
        let file_hash = md5(string: self.filename)
        print(self.destpath)
        
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: file_hash)
        let backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        let downloadTask = backgroundSession.downloadTask(with: url)
        downloadTask.resume()
    }
}
