//
//  Globals.swift
//  Kodi Remote 
//
//  Created by Quixom Technology on 01/01/16.
//  Copyright © 2016 Quixom Technology. All rights reserved.
//

import Foundation
import UPnAtom
import GCDWebServer


var global_ipaddress: String = ""
var global_port: String = ""
let backgroundColors = [0xFF2D55, 0x5856D6, 0x007AFF, 0x34AADC, 0x5AC8FA, 0x4CD964, 0xFF3B30, 0xFF9500, 0xFFCC00, 0x8E8E93, 0xC7C7CC, 0xD6CEC3]

var tvshow_id: Int = 0
var movie_id: Int = 0

var _discoveredDeviceUSNs = [UniqueServiceName]()
var _discoveredUPnPObjectCache = [UniqueServiceName: AbstractUPnP]()
var webServer: GCDWebServer! = nil

var downloadQueue = NSMutableDictionary()
