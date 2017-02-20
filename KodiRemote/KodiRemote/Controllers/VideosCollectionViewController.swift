//
//  CastCollectionViewController.swift
//  Kodi Remote
//
//  Created by Quixom Technology on 09/05/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit
import Photos
import UPnAtom

private let reuseIdentifier = "VideoCell"

class VideosCastCollectionViewController: UICollectionViewController {
    
    var videoAssets = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getLocalVideos()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.videoAssets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! VideoCollectionViewCell
        
        let inAsset = self.videoAssets[(indexPath as NSIndexPath).row]
        
        let _ = PHImageManager.default().requestImage(for: inAsset, targetSize: CGSize(width: 200, height: 200), contentMode: PHImageContentMode.aspectFill, options: PHImageRequestOptions(), resultHandler: { (result, info) -> Void in
            
            if( (info!["PHImageResultIsDegradedKey"] as! Int) == 1 ){
                cell.thumbnail.image = result!
            }
        })
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let deviceUSN = _discoveredDeviceUSNs[0]
        let deviceCache = _discoveredUPnPObjectCache
        let device = deviceCache[deviceUSN] as! AbstractUPnPDevice
        
        let mediaRenderer = device as? MediaRenderer1Device
        
        if mediaRenderer!.avTransportService == nil {
            print("\(mediaRenderer!.friendlyName) - has no AV transport service")
            return
        }
        
        let inAsset = self.videoAssets[(indexPath as NSIndexPath).row]
        
        let imageManager = PHImageManager.default()
        let videoRequestOptions = PHVideoRequestOptions()
        
        videoRequestOptions.deliveryMode = .highQualityFormat
        videoRequestOptions.version = .current
        videoRequestOptions.isNetworkAccessAllowed = true
        
        remove_content()
        
        let activity_indicator = ActivityIndicator()
        activity_indicator.progressBarDisplayer("Sending Video", true, view: self.view)
        
        imageManager.requestAVAsset(forVideo: inAsset, options: videoRequestOptions){ avAsset, avAudioMix, info in
            
            if let nextURLAsset = avAsset as? AVURLAsset {
                
                let sourceURL = nextURLAsset.url
                
                let source_url = sourceURL.absoluteString.replacingOccurrences(of: "file://", with: "")
                
                let filemanager = FileManager.default
                let home_dir = NSHomeDirectory() + "/media/"
                
                do {
                    let destination_path = home_dir + sourceURL.lastPathComponent
                    try filemanager.copyItem(atPath: source_url, toPath: destination_path)
                    
                    DispatchQueue.main.async {
                        activity_indicator.messageFrame.removeFromSuperview()
                    }
                    
                    let resource = PHAssetResource.assetResources(for: inAsset)
                    
                    if let resource = resource.first {
                        let url = URL(string: webServer.serverURL.absoluteString + resource.originalFilename)
                        
                        CastPlayer.sharedInstance.mediaRenderer = mediaRenderer
                        
                        CastPlayer.sharedInstance.startPlayback(url!)
                    }
                }catch let err as NSError {
                    print(err)
                    DispatchQueue.main.async {
                        activity_indicator.messageFrame.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    func getLocalVideos() {
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum , subtype: .smartAlbumVideos , options: nil)
        
        for i in 0  ..< assetCollections.count {
            let assetCollection = assetCollections[i]
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.video.rawValue)
            
            let assetsInCollection  = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
            
            if assetsInCollection.count > 0 {
                
                for j in 0 ..< assetsInCollection.count {
                    let inAsset = assetsInCollection[j] 
                    self.videoAssets.append(inAsset)
                }
            }
        }
    }
    
}
