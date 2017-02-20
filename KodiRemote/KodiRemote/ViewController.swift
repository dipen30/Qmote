//
//  ViewController.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 01/02/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var navbar: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navbar.target = self.revealViewController()
        navbar.action = #selector(SWRevealViewController.revealToggle(_:))
        
        //self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        //let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        //view.addGestureRecognizer(tap)
        
        //self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }


}

