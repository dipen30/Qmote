//
//  DiscoveryTableViewController.swift
//  KodiRemote
//
//  Created by Quixom Technology on 25/01/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class DiscoveryTableViewController: BaseTableViewController, NSNetServiceDelegate, NSNetServiceBrowserDelegate {

    let browser = NSNetServiceBrowser()
    var services: NSMutableArray = []
    var serviceNames = [String]()
    var serviceImages = [String]()
    var serviceIps = [String]()
    var servicePorts = [Int]()
    
    var rc: RemoteCalls!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.browser.delegate = self
        self.browser.searchForServicesOfType("_http._tcp", inDomain: "local.")

    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.serviceNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DiscoveryTableViewCell", forIndexPath: indexPath) as! DiscoveryTableViewCell
        
        let row = indexPath.row
        cell.serviceName.text = self.serviceNames[row]
        cell.serviceIp.text = self.serviceIps[row]
        cell.servicePort.text = String(self.servicePorts[row])
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0.0, cell.frame.height - 1, cell.frame.width, 0.5)
        bottomLine.backgroundColor = UIColor.grayColor().CGColor
        cell.layer.addSublayer(bottomLine)
        cell.clipsToBounds = true
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        global_ipaddress = self.serviceIps[indexPath.row]
        global_port = String(self.servicePorts[indexPath.row])
        
        rc = RemoteCalls(ipaddress: global_ipaddress, port: global_port)
        
        self.browser.stop()
    }
    
    func updateTable(){
        for service in self.services {
            let result = jsonifyService(service as! NSNetService)
            
            for (key, value) in result {
                if key as! String == "name" {
                    self.serviceNames.append(value as! String)
                }
                
                if key as! String == "port" {
                    self.servicePorts.append(value as! Int)
                }
                
                if key as! String == "addresses" {
                    if value.count > 0 {
                        self.serviceIps.append(value[0] as! String)
                    }else{
                        self.serviceIps.append("")
                    }
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
    func clearVariables(){
        self.serviceNames.removeAll()
        self.servicePorts.removeAll()
        self.serviceIps.removeAll()
    }
    
    func netServiceBrowser(netServiceBrowser: NSNetServiceBrowser,
        didFindService netService: NSNetService,
        moreComing moreServicesComing: Bool) {
            netService.delegate = self
            netService.resolveWithTimeout(0)
            self.services.addObject(netService) // keep strong reference to catch didResolveAddress
    }
    
    func netServiceBrowser(netServiceBrowser: NSNetServiceBrowser,
        didRemoveService netService: NSNetService,
        moreComing moreServicesComing: Bool) {
            self.clearVariables()
            self.services.removeObject(netService)
            
            if !moreServicesComing {
                self.updateTable()
            }
    }
    
    func netServiceDidResolveAddress(netService: NSNetService) {
        self.clearVariables()
        self.updateTable()
    }
    
    private func jsonifyService(netService: NSNetService) -> NSDictionary {
        
        let addresses: [String] = IP(netService.addresses)
        
        var txtRecord: [String: String] = [:]
        let dict = NSNetService.dictionaryFromTXTRecordData(netService.TXTRecordData()!)
        for (key, data) in dict {
            txtRecord[key] = String(data: data, encoding:NSUTF8StringEncoding)
        }
        
        let service: NSDictionary = NSDictionary(
            objects: [netService.domain, netService.type, netService.port, netService.name, addresses, txtRecord],
            forKeys: ["domain", "type", "port", "name", "addresses", "txtRecord"])
        
        return service
    }
    
    // http://dev.eltima.com/post/99996366184/using-bonjour-in-swift
    private func IP(addresses: [NSData]?) -> [String] {
        var ips: [String] = []
        if addresses != nil {
            for addressBytes in addresses! {
                var inetAddress : sockaddr_in!
                var inetAddress6 : sockaddr_in6!
                //NSData’s bytes returns a read-only pointer to the receiver’s contents.
                let inetAddressPointer = UnsafePointer<sockaddr_in>(addressBytes.bytes)
                //Access the underlying raw memory
                inetAddress = inetAddressPointer.memory
                if inetAddress.sin_family == __uint8_t(AF_INET) {
                }
                else {
                    if inetAddress.sin_family == __uint8_t(AF_INET6) {
                        let inetAddressPointer6 = UnsafePointer<sockaddr_in6>(addressBytes.bytes)
                        inetAddress6 = inetAddressPointer6.memory
                        inetAddress = nil
                    }
                    else {
                        inetAddress = nil
                    }
                }
                var ipString : UnsafePointer<CChar>?
                //static func alloc(num: Int) -> UnsafeMutablePointer
                let ipStringBuffer = UnsafeMutablePointer<CChar>.alloc(Int(INET6_ADDRSTRLEN))
                if inetAddress != nil {
                    var addr = inetAddress.sin_addr
                    ipString = inet_ntop(Int32(inetAddress.sin_family),
                        &addr,
                        ipStringBuffer,
                        __uint32_t (INET6_ADDRSTRLEN))
                } else {
                    if inetAddress6 != nil {
                        var addr = inetAddress6.sin6_addr
                        ipString = inet_ntop(Int32(inetAddress6.sin6_family),
                            &addr,
                            ipStringBuffer,
                            __uint32_t(INET6_ADDRSTRLEN))
                    }
                }
                if ipString != nil {
                    let ip = String.fromCString(ipString!)
                    if ip != nil {
                        ips.append(ip!)
                    }
                }
            }
        }
        return ips
    }
}
