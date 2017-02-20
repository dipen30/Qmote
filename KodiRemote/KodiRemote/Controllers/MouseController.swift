//
//  MouseController.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 18/12/15.
//  Copyright © 2015 Quixom Technology. All rights reserved.
//

import Foundation


class MouseController: ViewController {
    var client: UDPClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        client = UDPClient(addr: global_ipaddress, port: 12345)
        
        let leftclick = UITapGestureRecognizer(target: self, action: #selector(left_click))
        leftclick.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(leftclick)
        
        let rightclick = UITapGestureRecognizer(target: self, action: #selector(right_click))
        rightclick.numberOfTapsRequired = 1
        rightclick.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(rightclick)
        
        let doubleclick = UITapGestureRecognizer(target: self, action: #selector(double_click))
        doubleclick.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleclick)
        // disable single tap event
        leftclick.require(toFail: doubleclick)
        
        let mouse_move = UIPanGestureRecognizer(target: self, action: #selector(moveMouse))
        self.view.addGestureRecognizer(mouse_move)
        
        let scroll = UIPanGestureRecognizer(target: self, action: #selector(scroll_page))
        scroll.minimumNumberOfTouches = 2
        self.view.addGestureRecognizer(scroll)
        
    }
    
    func moveMouse(_ sender:UIPanGestureRecognizer){
        
        let x = Int(sender.translation(in: self.view).x)
        let y = Int(sender.translation(in: self.view).y)
        
        let str = "mm:\(x)/\(y)"
        let _ = client.send(str: str)
        
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    func scroll_page(_ sender: UIPanGestureRecognizer){
        let y = Int(sender.translation(in: self.view).y)
        
        let str = "ms:\(y)"
        let _ = client.send(str: str)
        
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    func double_click(){
        let _ = client.send(str: "dc:")
    }
    
    func left_click() {
        let _ = client.send(str: "lc:")
    }
    
    func right_click() {
        let _ = client.send(str: "rc:")
    }
    
}
