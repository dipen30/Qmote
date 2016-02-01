//
//  BaseTableViewController.swift
//  KodiRemote
//
//  Created by Quixom Technology on 30/12/15.
//  Copyright © 2015 Quixom Technology. All rights reserved.
//

import UIKit


class BaseTableViewController: UITableViewController {

    @IBOutlet var navbar: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navbar.target = self.revealViewController()
        navbar.action = "revealToggle:"
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

}
