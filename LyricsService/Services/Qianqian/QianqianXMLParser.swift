//
//  QianqianXMLParser.swift
//  LyricsX
//
//  Created by Eru on 2017/7/1.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa
import Private.Qianqian

class QianqianXMLParser: NSObject {
    
    fileprivate var qianqianLyrics: [WebLyrics]
    fileprivate var info: SearchInfo!
    fileprivate var qianqianLyricsBaseURL: String
    
    init(lyricsBaseURL: String) {
        qianqianLyrics = []
        qianqianLyricsBaseURL = lyricsBaseURL
        super.init()
    }
    
    func parse(lyricsData: Data, info: SearchInfo) -> [WebLyrics] {
        self.info = info
        qianqianLyrics.removeAll()
        
        let xmlParser = XMLParser(data: lyricsData)
        xmlParser.delegate = self
        xmlParser.parse()
        return qianqianLyrics
    }
}

extension QianqianXMLParser: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        guard elementName == "lrc",
              let songID = attributeDict["id"],
              let artist = attributeDict["artist"],
              let title = attributeDict["title"],
              let accessKey = QianqianDecrypt.accessCode(withArtist: artist, title: title, songID: Int(songID)!)
        else { return }
        
        let url = String(format: qianqianLyricsBaseURL, songID, accessKey)
        let webLyrics = QianqianWebLyrics(info: info, url: url, title: title, artist: artist)
        qianqianLyrics.append(webLyrics)
    }
}
