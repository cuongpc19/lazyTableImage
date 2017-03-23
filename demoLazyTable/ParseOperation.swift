//
//  ParseOperation.swift
//  demoLazyTable
//
//  Created by AgribankCard on 3/22/17.
//  Copyright © 2017 cuongpc. All rights reserved.
//

import Foundation
class ParseOperation: Operation, XMLParserDelegate {
    var errorHandler: ((Error) -> Void)?
    private(set) var appRecordList: [AppRecord]?
    // string contants found in the RSS feed
    let kIDStr = "id"
    let kNameStr = "im:name"
    let kImageStr = "im:image"
    let kArtistStr = "im:artist"
    let kEntryStr = "entry"

    private var dataToParse: Data
    private var workingArray: [AppRecord] = []
    private var workingEntry: AppRecord?
    private var workingPropertyString: String = ""
    private var elementsToParse: [String]
    private var storingCharacterData: Bool = false

    init(data: Data) {
        dataToParse = data
        elementsToParse = [kIDStr, kNameStr, kImageStr, kArtistStr]
    }
    override func main() {
        let parser = XMLParser(data: self.dataToParse)
        parser.delegate = self
        parser.parse()
        
        if !self.isCancelled {
            // Set appRecordList to the result of our parsing
            self.appRecordList = self.workingArray
        }
        
        self.workingArray = []
        self.workingPropertyString = ""
        self.dataToParse = Data()
    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        // entry: { id (link), im:name (app name), im:image (variable height) }
        //
        if elementName == kEntryStr {
            self.workingEntry = AppRecord()
        }
        self.storingCharacterData = self.elementsToParse.index(of: elementName) != nil
    }
    
    // -------------------------------------------------------------------------------
    //	parser:didEndElement:namespaceURI:qualifiedName:
    // -------------------------------------------------------------------------------
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let workingEntry = self.workingEntry {
            if self.storingCharacterData {
                let trimmedString =
                    self.workingPropertyString.trimmingCharacters(
                        in: CharacterSet.whitespacesAndNewlines)
                self.workingPropertyString = ""
                switch elementName {
                case kIDStr:
                    workingEntry.appURLString = trimmedString
                case kNameStr:
                    workingEntry.appName = trimmedString
                case kImageStr:
                    workingEntry.imageURLString = trimmedString
                case kArtistStr:
                    workingEntry.artist = trimmedString
                default:
                    break
                }
            } else if elementName == kEntryStr {
                workingArray.append(workingEntry)
                self.workingEntry = nil
            }
        }
    }
    
    // -------------------------------------------------------------------------------
    //	parser:foundCharacters:
    // -------------------------------------------------------------------------------
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if storingCharacterData {
            self.workingPropertyString += string
        }
    }
    
    // -------------------------------------------------------------------------------
    //	parser:parseErrorOccurred:
    // -------------------------------------------------------------------------------
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.errorHandler?(parseError)
    }
}
