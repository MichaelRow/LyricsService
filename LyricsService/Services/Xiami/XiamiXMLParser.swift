//
//  XiamiXMLParser.swift
//  LyricsX
//
//  Created by Eru on 2017/7/2.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa

class XiamiXMLParser: NSObject {
    
    private var currentValue: String?
    private var trackInfoKeys = [String:String]()
    private var valueCDATA: String?
    
    func parse(data: Data, info: SearchInfo) -> WebLyrics? {
        
        currentValue = nil
        trackInfoKeys.removeAll()
        
        let xmlParser = XMLParser(data: data)
        xmlParser.delegate = self
        xmlParser.shouldProcessNamespaces = true
        xmlParser.parse()
        
        guard let lyricsURL = trackInfoKeys["lrcURL"] else { return nil }
        let title = trackInfoKeys["title"]
        let artist = trackInfoKeys["artist"]
        let album = trackInfoKeys["album"]
        
        let xiamiLyrics = XiamiWebLyrics(info: info, url: lyricsURL, title: title, artist: artist, album: album)
        return xiamiLyrics
    }
}

//MARK: XMLParserDelegate

extension XiamiXMLParser: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard currentValue != nil else { return }
        
        switch elementName {
        case "lyric":
            trackInfoKeys["lrcURL"] = currentValue!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
        case "album_pic":
            trackInfoKeys["artworkURL"] = currentValue!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        case "songName":
            trackInfoKeys["title"] = currentValue!.trimmingCharacters(in: CharacterSet.newlines)
            
        case "singers":
            trackInfoKeys["artist"] = currentValue!.trimmingCharacters(in: CharacterSet.newlines)
            
        case "album_name":
            foundAlbum()
            
        default:
            valueCDATA = nil
        }
        
        currentValue = nil
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        valueCDATA = String(data: CDATABlock, encoding: .utf8)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentValue == nil {
            currentValue = String()
        }
        currentValue!.append(string)
    }
    
    func foundAlbum() {
        guard let valueCDATA = valueCDATA else { return }
        trackInfoKeys["album"] = valueCDATA
    }
}
