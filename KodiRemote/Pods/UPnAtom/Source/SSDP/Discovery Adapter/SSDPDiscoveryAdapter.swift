//
//  AVTransport1Event.swift
//
//  Copyright (c) 2015 David Robles
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

protocol SSDPDiscoveryAdapterDelegate: class {
    func ssdpDiscoveryAdapter(_ adapter: SSDPDiscoveryAdapter, didUpdateSSDPDiscoveries ssdpDiscoveries: [SSDPDiscovery])
    /// Assume discovery adapter has stopped after a failure.
    func ssdpDiscoveryAdapter(_ adapter: SSDPDiscoveryAdapter, didFailWithError error: NSError)
}

/// Provides an interface to allow any SSDP library to be used an adapted into UPnAtom for SSDP discovery.
protocol SSDPDiscoveryAdapter: class {
    var rawSSDPTypes: Set<String> { get set }
    weak var delegate: SSDPDiscoveryAdapterDelegate? { get set }
    var running: Bool { get }
    func start()
    func stop()
    func restart()
}

/// An abstract class to allow any SSDP library to be used an adapted into UPnAtom for SSDP discovery.
class AbstractSSDPDiscoveryAdapter: SSDPDiscoveryAdapter {
    var rawSSDPTypes: Set<String> = []
    weak var delegate: SSDPDiscoveryAdapterDelegate?
    var delegateQueue = DispatchQueue.main
    fileprivate(set) var running = false
    
    required init() { }
    
    func start() {
        running = true
    }
    
    func stop() {
        running = false
    }
    
    func restart() {
        if running {
            stop()
        }
        start()
    }
    
    /// 🔰 = protected
    ///
    /// Sets running = false.
    func failed🔰() {
        running = false
    }
}
