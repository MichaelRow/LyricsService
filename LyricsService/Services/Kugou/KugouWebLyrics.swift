//
//  KugouWebLyrics.swift
//  LyricsX
//
//  Created by Eru on 2017/6/30.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

private let KugouGetLyricsURL = "http://lyrics.kugou.com/download"

class KugouWebLyrics {
    
    var searchInfo: SearchInfo
    
    var serverTitle: String?
    
    var serverArtist: String?
    
    var serverAlbum: String?
    
    var lyrics: Lyrics?
    
    fileprivate var accessKey: String
    
    fileprivate var songID: String
    
    init(info: SearchInfo, accessKey: String, songID: String, title: String? = nil, artist: String? = nil) {
        self.searchInfo = info
        self.accessKey = accessKey
        self.songID = songID
        self.serverTitle = title
        self.serverArtist = artist
    }
}

extension KugouWebLyrics: WebLyrics {
    var sourceInfo: LyricsSourceInfo { return .Kugou }
    var lyricsType: LyricsType { return .Krc }
}

extension KugouWebLyrics: DownloadableWebLyrics {
    
    var requestURL: String { return KugouGetLyricsURL }
    
    var httpHeaders: HTTPHeaders? { return nil }
    
    var parameters: Parameters? {
        return [ "ver"       :  "1",
                 "client"    :  "pc",
                 "charset"   :  "utf8",
                 "fmt"       :  "krc",
                 "id"        :  songID,
                 "accesskey" :  accessKey]
    }
    
    func handle(response: String) -> Lyrics? {
        guard let content = JSON(parseJSON: response)["content"].string else { return nil }
        return lyricsType.decoder.decode(content)
    }
}
