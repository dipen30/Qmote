//
//  BaseTabBarController.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 04/01/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {

    @IBOutlet var navbar: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navbar.target = self.revealViewController()
        navbar.action = #selector(SWRevealViewController.revealToggle(_:))
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
    }
    
}
