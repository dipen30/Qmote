//
//  DiscoveryTableViewController.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 25/01/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import UIKit

class DiscoveryTableViewController: BaseTableViewController, NetServiceDelegate, NetServiceBrowserDelegate {

    let browser = NetServiceBrowser()
    var services: NSMutableArray = []
    var serviceNames = [String]()
    var serviceImages = [String]()
    var serviceIps = [String]()
    var servicePorts = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.browser.delegate = self
        self.browser.searchForServices(ofType: "_http._tcp", inDomain: "local.")

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.serviceNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoveryTableViewCell", for: indexPath) as! DiscoveryTableViewCell
        
        let row = (indexPath as NSIndexPath).row
        cell.serviceName.text = self.serviceNames[row]
        cell.serviceIp.text = self.serviceIps[row]
        cell.servicePort.text = String(self.servicePorts[row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        global_ipaddress = self.serviceIps[(indexPath as NSIndexPath).row]
        global_port = String(self.servicePorts[(indexPath as NSIndexPath).row])
        
        let previous_ip = UserDefaults.standard
        previous_ip.setValue(global_ipaddress, forKey: "ip")
        previous_ip.setValue(global_port, forKey: "port")
        
        self.browser.stop()
    }
    
    func updateTable(){
        for service in self.services {
            let result = jsonifyService(service as! NetService)
            
            for (key, value) in result {
                if key as! String == "name" {
                    self.serviceNames.append(value as! String)
                }
                
                if key as! String == "port" {
                    self.servicePorts.append(value as! Int)
                }
                
                if key as! String == "addresses" {
                    if (value as AnyObject).count > 0 {
                        self.serviceIps.append((value as! NSArray)[0] as! String)
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
    
    func netServiceBrowser(_ netServiceBrowser: NetServiceBrowser,
        didFind netService: NetService,
        moreComing moreServicesComing: Bool) {
            netService.delegate = self
            netService.resolve(withTimeout: 0)
            self.services.add(netService) // keep strong reference to catch didResolveAddress
    }
    
    func netServiceBrowser(_ netServiceBrowser: NetServiceBrowser,
        didRemove netService: NetService,
        moreComing moreServicesComing: Bool) {
            self.clearVariables()
            self.services.remove(netService)
            
            if !moreServicesComing {
                self.updateTable()
            }
    }
    
    func netServiceDidResolveAddress(_ netService: NetService) {
        self.clearVariables()
        self.updateTable()
    }
    
    fileprivate func jsonifyService(_ netService: NetService) -> NSDictionary {
        
        let addresses: [String] = IP(netService.addresses)
        
        var txtRecord: [String: String] = [:]
        let dict = NetService.dictionary(fromTXTRecord: netService.txtRecordData()!)
        for (key, data) in dict {
            txtRecord[key] = String(data: data, encoding:String.Encoding.utf8)
        }
        
        let service: NSDictionary = NSDictionary(
            objects: [netService.domain, netService.type, netService.port, netService.name, addresses, txtRecord],
            forKeys: ["domain" as NSCopying, "type" as NSCopying, "port" as NSCopying, "name" as NSCopying, "addresses" as NSCopying, "txtRecord" as NSCopying])
        
        return service
    }
    
    // http://dev.eltima.com/post/99996366184/using-bonjour-in-swift
    fileprivate func IP(_ addresses: [Data]?) -> [String] {
        var ips: [String] = []
        if addresses != nil {
            for addressBytes in addresses! {
                var inetAddress : sockaddr_in!
                var inetAddress6 : sockaddr_in6!
                //NSData’s bytes returns a read-only pointer to the receiver’s contents.
                let inetAddressPointer = (addressBytes as NSData).bytes.bindMemory(to: sockaddr_in.self, capacity: addressBytes.count)
                //Access the underlying raw memory
                inetAddress = inetAddressPointer.pointee
                if inetAddress.sin_family == __uint8_t(AF_INET) {
                }
                else {
                    if inetAddress.sin_family == __uint8_t(AF_INET6) {
                        let inetAddressPointer6 = (addressBytes as NSData).bytes.bindMemory(to: sockaddr_in6.self, capacity: addressBytes.count)
                        inetAddress6 = inetAddressPointer6.pointee
                        inetAddress = nil
                    }
                    else {
                        inetAddress = nil
                    }
                }
                var ipString : UnsafePointer<CChar>?
                //static func alloc(num: Int) -> UnsafeMutablePointer
                let ipStringBuffer = UnsafeMutablePointer<CChar>.allocate(capacity: Int(INET6_ADDRSTRLEN))
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
                    let ip = String(cString: ipString!)
                    if !ip.isEmpty {
                        ips.append(ip)
                    }
                }
            }
        }
        return ips
    }
}
