//
//  RemoteController.swift
//  KodiRemote
//
//  Created by Quixom Technology on 18/12/15.
//  Copyright © 2015 Quixom Technology. All rights reserved.
//

import Foundation


class RemoteController: ViewController {
	
	@IBOutlet var ipTextbox: UITextField!
	@IBOutlet var portTextBox: UITextField!
	@IBOutlet var errorLable: UILabel!
	
	var rc: RemoteCalls!
	
	override func viewDidAppear(animated: Bool) {
        if global_ipaddress == "" {
            let discovery = self.storyboard?.instantiateViewControllerWithIdentifier("DiscoveryView") as! DiscoveryTableViewController
            self.navigationController?.pushViewController(discovery, animated: true)
        }
        
        if global_ipaddress != "" {
            ipTextbox.text = global_ipaddress
            portTextBox.text = global_port
            
            rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        }
	}
	
	@IBAction func saveButton(sender: AnyObject) {
		let ipaddr = ipTextbox.text!
		let port = portTextBox.text!
		
		let validIpAddressRegex = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
		
		if ipaddr.isEmpty {
			errorLable.text = "Please Enter IP address."
			return
		}else if (ipaddr.rangeOfString(validIpAddressRegex, options: .RegularExpressionSearch) == nil){
			errorLable.text = "Please Enter Valid IP address."
			return
		}
		
		if port.isEmpty {
			errorLable.text = "Please Enter Port Number."
			return
		}
		
		errorLable.text = ""
        
        global_ipaddress = ipaddr
        global_port = port
		
		rc = RemoteCalls(ipaddress: ipaddr, port: port)
	}
	
	@IBAction func leftButton(sender: AnyObject) {
        rc.jsonRpcCall("Input.Left"){(response: NSDictionary?) in
        }
	}
	
	@IBAction func rightButton(sender: AnyObject) {
        rc.jsonRpcCall("Input.Right"){(response: NSDictionary?) in
        }
	}
	
	@IBAction func downButton(sender: AnyObject) {
        rc.jsonRpcCall("Input.Down"){(response: NSDictionary?) in
        }
	}
	
	@IBAction func upButton(sender: AnyObject) {
        rc.jsonRpcCall("Input.Up"){(response: NSDictionary?) in
        }
	}
	
	@IBAction func okButton(sender: AnyObject) {
        rc.jsonRpcCall("Input.Select"){(response: NSDictionary?) in
        }
	}
	
	@IBAction func homeButton(sender: AnyObject) {
        rc.jsonRpcCall("Input.Home"){(response: NSDictionary?) in
        }
	}
	
	@IBAction func backButton(sender: AnyObject) {
        rc.jsonRpcCall("Input.Back"){(response: NSDictionary?) in
        }
	}
	
	@IBAction func videoButton(sender: AnyObject) {
        rc.jsonRpcCall("GUI.ActivateWindow", params: "{\"window\": \"videos\"}"){(response: NSDictionary?) in
        }
	}
	
	@IBAction func moviesButton(sender: AnyObject) {
        rc.jsonRpcCall("GUI.ActivateWindow", params: "{\"window\": \"video\"}"){(response: NSDictionary?) in
        }
	}
	
	@IBAction func musicButton(sender: AnyObject) {
        rc.jsonRpcCall("GUI.ActivateWindow", params: "{\"window\": \"music\"}"){(response: NSDictionary?) in
        }
	}
	
	@IBAction func pictureButton(sender: AnyObject) {
        rc.jsonRpcCall("GUI.ActivateWindow", params: "{\"window\": \"pictures\"}"){(response: NSDictionary?) in
        }
	}
	
}