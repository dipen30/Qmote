//
//  Player.swift
//  Kodi Remote
//
//  Created by Quixom Technology on 09/05/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit
import UPnAtom

private let _PlayerSharedInstance = CastPlayer()

class CastPlayer {
    class var sharedInstance: CastPlayer {
        return _PlayerSharedInstance
    }
    var mediaServer: MediaServer1Device?
    var mediaRenderer: MediaRenderer1Device? {
        didSet {
            didSetRenderer(oldRenderer: oldValue, newRenderer: mediaRenderer)
        }
    }
    
    fileprivate var _playlist: URL?
    fileprivate var _avTransportEventObserver: AnyObject?
    fileprivate var _avTransportInstanceID = "0"
    
    enum PlayerState {
        case unknown
        case stopped
        case playing
        case paused
    }
    
    func startPlayback(_ playlist: URL) {
        _playlist = playlist
        
        startPlayback()
    }
    
    func startPlayback() {
        let item = _playlist! as URL
        
        let uri = item.absoluteString
        let instanceID = _avTransportInstanceID
        mediaRenderer?.avTransportService?.setAVTransportURI(instanceID: instanceID, currentURI: uri, currentURIMetadata: "", success: { () -> Void in
            print("URI set succeeded!")
            self.play({ () -> Void in
                print("Play command succeeded!")
                }, failure: { (error) -> Void in
                    print("Play command failed: \(error)")
            })
            
            }, failure: { (error) -> Void in
                print("URI set failed: \(error)")
        })
    }
    
    fileprivate func didSetRenderer(oldRenderer: MediaRenderer1Device?, newRenderer: MediaRenderer1Device?) {
        if let avTransportEventObserver: AnyObject = _avTransportEventObserver {
            oldRenderer?.avTransportService?.removeEventObserver(avTransportEventObserver)
        }
        
        _avTransportEventObserver = newRenderer?.avTransportService?.addEventObserver(OperationQueue.current, callBackBlock: { (event: UPnPEvent) -> Void in
            if let avTransportEvent = event as? AVTransport1Event,
                let transportState = (avTransportEvent.instanceState["TransportState"] as? String)?.lowercased() {
                print("\(event.service?.className) Event: \(avTransportEvent.instanceState)")
                print("transport state: \(transportState)")
            }
        })
    }
    
    fileprivate func play(_ success: @escaping () -> Void, failure:@escaping (_ error: NSError) -> Void) {
        self.mediaRenderer?.avTransportService?.play(instanceID: _avTransportInstanceID, speed: "1", success: success, failure: failure)
    }
    
    fileprivate func pause(_ success: @escaping () -> Void, failure:@escaping (_ error: NSError) -> Void) {
        self.mediaRenderer?.avTransportService?.pause(instanceID: _avTransportInstanceID, success: success, failure: failure)
    }
    
    fileprivate func stop(_ success: @escaping () -> Void, failure:@escaping (_ error: NSError) -> Void) {
        self.mediaRenderer?.avTransportService?.stop(instanceID: _avTransportInstanceID, success: success, failure: failure)
    }
}
