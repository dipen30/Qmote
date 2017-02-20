//
//  ContentDirectory1Object.swift
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

import Foundation
import Ono

// MARK: ContentDirectory1Object

/// TODO: For now rooting to NSObject to expose to Objective-C, see Github issue #16
open class ContentDirectory1Object: NSObject {
    open let objectID: String
    open let parentID: String
    open let title: String
    open let rawType: String
    open let albumArtURL: URL?
    
    init?(xmlElement: ONOXMLElement) {
        if let objectID = xmlElement.value(forAttribute: "id") as? String,
            let parentID = xmlElement.value(forAttribute: "parentID") as? String,
            let title = xmlElement.firstChild(withTag: "title").stringValue(),
            let rawType = xmlElement.firstChild(withTag: "class").stringValue() {
                self.objectID = objectID
                self.parentID = parentID
                self.title = title
                self.rawType = rawType
                
                if let albumArtURLString = xmlElement.firstChild(withTag: "albumArtURI")?.stringValue() {
                    self.albumArtURL = URL(string: albumArtURLString)
                } else { albumArtURL = nil }
        } else {
            /// TODO: Remove default initializations to simply return nil, see Github issue #11
            objectID = ""
            parentID = ""
            title = ""
            rawType = ""
            albumArtURL = nil
            super.init()
            return nil
        }
        
        super.init()
    }
}

extension ContentDirectory1Object: ExtendedPrintable {
    #if os(iOS)
    public var className: String { return "\(type(of: self))" }
    #elseif os(OSX) // NSObject.className actually exists on OSX! Who knew.
    override public var className: String { return "\(type(of: self))" }
    #endif
    override open var description: String {
        var properties = PropertyPrinter()
        properties.add("id", property: objectID)
        properties.add("parentID", property: parentID)
        properties.add("title", property: title)
        properties.add("class", property: rawType)
        properties.add("albumArtURI", property: albumArtURL?.absoluteString)
        return properties.description
    }
}

// MARK: - ContentDirectory1Container

open class ContentDirectory1Container: ContentDirectory1Object {
    open let childCount: Int?
    
    override init?(xmlElement: ONOXMLElement) {
        self.childCount = Int(String(describing: xmlElement.value(forAttribute: "childCount")))
        
        super.init(xmlElement: xmlElement)
    }
}

/// for objective-c type checking
extension ContentDirectory1Object {
    public func isContentDirectory1Container() -> Bool {
        return self is ContentDirectory1Container
    }
}

/// overrides ExtendedPrintable protocol implementation
extension ContentDirectory1Container {
    override public var className: String { return "\(type(of: self))" }
    override open var description: String {
        var properties = PropertyPrinter()
        properties.add(super.className, property: super.description)
        properties.add("childCount", property: "\(childCount)")
        return properties.description
    }
}

// MARK: - ContentDirectory1Item

open class ContentDirectory1Item: ContentDirectory1Object {
    open let resourceURL: URL!
    
    override init?(xmlElement: ONOXMLElement) {
        /// TODO: Return nil immediately instead of waiting, see Github issue #11
        if let resourceURLString = xmlElement.firstChild(withTag: "res").stringValue() {
            resourceURL = URL(string: resourceURLString)
        } else { resourceURL = nil }
        
        super.init(xmlElement: xmlElement)
        
        guard resourceURL != nil else {
            return nil
        }
    }
}

/// for objective-c type checking
extension ContentDirectory1Object {
    public func isContentDirectory1Item() -> Bool {
        return self is ContentDirectory1Item
    }
}

/// overrides ExtendedPrintable protocol implementation
extension ContentDirectory1Item {
    override public var className: String { return "\(type(of: self))" }
    override open var description: String {
        var properties = PropertyPrinter()
        properties.add(super.className, property: super.description)
        properties.add("resourceURL", property: resourceURL?.absoluteString)
        return properties.description
    }
}

// MARK: - ContentDirectory1VideoItem

open class ContentDirectory1VideoItem: ContentDirectory1Item {
    open let bitrate: Int?
    open let duration: TimeInterval?
    open let audioChannelCount: Int?
    open let protocolInfo: String?
    open let resolution: CGSize?
    open let sampleFrequency: Int?
    open let size: Int?
    
    override init?(xmlElement: ONOXMLElement) {
        bitrate = Int(String(describing: xmlElement.firstChild(withTag: "res").value(forAttribute: "bitrate")))
        
        if let durationString = xmlElement.firstChild(withTag: "res").value(forAttribute: "duration") as? String {
            let durationComponents = durationString.components(separatedBy: ":")
            var count: Double = 0
            var duration: Double = 0
            for durationComponent in durationComponents.reversed() {
                duration += (durationComponent as NSString).doubleValue * pow(60, count)
                count += 1
            }
            
            self.duration = TimeInterval(duration)
        } else { self.duration = nil }
        
        audioChannelCount = Int(String(describing: xmlElement.firstChild(withTag: "res").value(forAttribute: "nrAudioChannels")))
        
        protocolInfo = xmlElement.firstChild(withTag: "res").value(forAttribute: "protocolInfo") as? String
        
        if let resolutionComponents = (xmlElement.firstChild(withTag: "res").value(forAttribute: "resolution") as? String)?.components(separatedBy: "x"),
            let width = Int(String(describing: resolutionComponents.first)),
            let height = Int(String(describing: resolutionComponents.last)) {
                resolution = CGSize(width: width, height: height)
        } else { resolution = nil }
        
        sampleFrequency = Int(String(describing: xmlElement.firstChild(withTag: "res").value(forAttribute: "sampleFrequency")))
        
        size = Int(String(describing: xmlElement.firstChild(withTag: "res").value(forAttribute: "size")))
        
        super.init(xmlElement: xmlElement)
    }
}

/// for objective-c type checking
extension ContentDirectory1Object {
    public func isContentDirectory1VideoItem() -> Bool {
        return self is ContentDirectory1VideoItem
    }
}

/// overrides ExtendedPrintable protocol implementation
extension ContentDirectory1VideoItem {
    override public var className: String { return "\(type(of: self))" }
    override open var description: String {
        var properties = PropertyPrinter()
        properties.add(super.className, property: super.description)
        properties.add("bitrate", property: "\(bitrate)")
        properties.add("duration", property: "\(duration)")
        properties.add("audioChannelCount", property: "\(audioChannelCount)")
        properties.add("protocolInfo", property: protocolInfo)
        properties.add("resolution", property: "\(resolution?.width)x\(resolution?.height)")
        properties.add("sampleFrequency", property: "\(sampleFrequency)")
        properties.add("size", property: "\(size)")
        return properties.description
    }
}
