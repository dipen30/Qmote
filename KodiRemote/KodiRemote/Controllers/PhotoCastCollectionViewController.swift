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
import GCDWebServer

private let reuseIdentifier = "PhotoCell"

class PhotoCastCollectionViewController: UICollectionViewController {
    
    var imageAssets = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startServer()
        
        DispatchQueue.main.async(execute: {
            self.getLocalImages()
            self.collectionView?.reloadData()
        })
        
        // initialize
        UPnAtom.sharedInstance.ssdpTypes = [
            SSDPTypeConstant.All.rawValue,
            SSDPTypeConstant.MediaRendererDevice1.rawValue,
            SSDPTypeConstant.AVTransport1Service.rawValue
        ]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceWasAdded), name: NSNotification.Name(rawValue: UPnPRegistry.UPnPDeviceAddedNotification()), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceWasRemoved), name: NSNotification.Name(rawValue: UPnPRegistry.UPnPDeviceRemovedNotification()), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(serviceWasAdded), name: NSNotification.Name(rawValue: UPnPRegistry.UPnPServiceAddedNotification()), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(serviceWasRemoved), name: NSNotification.Name(rawValue: UPnPRegistry.UPnPServiceRemovedNotification()), object: nil)
        
        self.performSSDPDiscovery()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageAssets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        let inAsset = self.imageAssets[(indexPath as NSIndexPath).row]
        
        let _ = PHImageManager.default().requestImage(for: inAsset, targetSize: CGSize(width: 200, height: 200), contentMode: PHImageContentMode.aspectFill, options: PHImageRequestOptions(), resultHandler: { (result, info) -> Void in
            
            if( (info!["PHImageResultIsDegradedKey"] as! Int) == 1 ){
                cell.photo.image = result!
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
        
        let inAsset = self.imageAssets[(indexPath as NSIndexPath).row]
        
        let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
            return true
        }
        
        remove_content()
        
        let activity_indicator = ActivityIndicator()
        activity_indicator.progressBarDisplayer("Sending Image", true, view: self.view)
        
        inAsset.requestContentEditingInput(with: options) { contentEditingInput, info in
            
            let sourceURL = contentEditingInput?.fullSizeImageURL
            
            let source_url = sourceURL!.absoluteString.replacingOccurrences(of: "file://", with: "")
            
            let filemanager = FileManager.default
            let home_dir = NSHomeDirectory() + "/media/"
            
            do {
                let destination_path = home_dir + sourceURL!.lastPathComponent
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
    
    private func deviceForIndexPath(_ indexPath: IndexPath) -> AbstractUPnPDevice {
        let deviceUSN = _discoveredDeviceUSNs[0]
        let deviceCache = _discoveredUPnPObjectCache
        return deviceCache[deviceUSN] as! AbstractUPnPDevice
    }
    
    
    @objc private func deviceWasAdded(_ notification: Notification) {
        if let upnpDevice = (notification as NSNotification).userInfo?[UPnPRegistry.UPnPDeviceKey()] as? AbstractUPnPDevice {
            
            if upnpDevice.baseURL.absoluteString.range(of: global_ipaddress) != nil {
                _discoveredUPnPObjectCache[upnpDevice.usn] = upnpDevice
                insertDevice(deviceUSN: upnpDevice.usn, deviceUSNs: &_discoveredDeviceUSNs)
            }
        }
    }
    
    @objc private func deviceWasRemoved(_ notification: Notification) {
        if let upnpDevice = (notification as NSNotification).userInfo?[UPnPRegistry.UPnPDeviceKey()] as? AbstractUPnPDevice {
            _discoveredUPnPObjectCache.removeValue(forKey: upnpDevice.usn)
            deleteDevice(deviceUSN: upnpDevice.usn, deviceUSNs: &_discoveredDeviceUSNs)
        }
    }
    
    @objc private func serviceWasAdded(_ notification: Notification) {
        if let upnpService = (notification as NSNotification).userInfo?[UPnPRegistry.UPnPServiceKey()] as? AbstractUPnPService {
            _discoveredUPnPObjectCache[upnpService.usn] = upnpService
        }
    }
    
    @objc private func serviceWasRemoved(_ notification: Notification) {
        if let upnpService = (notification as NSNotification).userInfo?[UPnPRegistry.UPnPServiceKey()] as? AbstractUPnPService {
            _discoveredUPnPObjectCache[upnpService.usn] = upnpService
        }
    }
    
    private func insertDevice(deviceUSN: UniqueServiceName, deviceUSNs: inout [UniqueServiceName]) {
        let index = deviceUSNs.count
        deviceUSNs.insert(deviceUSN, at: index)
    }
    
    private func deleteDevice(deviceUSN: UniqueServiceName, deviceUSNs: inout [UniqueServiceName]) {
        if let index = deviceUSNs.index(of: deviceUSN) {
            deviceUSNs.remove(at: index)
        }
    }
    
    private func performSSDPDiscovery() {
        if UPnAtom.sharedInstance.ssdpDiscoveryRunning() {
            UPnAtom.sharedInstance.restartSSDPDiscovery()
        }
        else {
            UPnAtom.sharedInstance.startSSDPDiscovery()
        }
    }
    
    func getLocalImages() {
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum , subtype: .any , options: nil)
        
        for i in 0 ..< assetCollections.count {
            let assetCollection = assetCollections[i]
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.image.rawValue)
            
            let assetsInCollection  = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
            
            if assetsInCollection.count > 0 {
                
                for j in 0 ..< assetsInCollection.count {
                    let inAsset = assetsInCollection[j] 
                    
                    self.imageAssets.append(inAsset)
                }
            }
        }
    }
    
}
