//
//  XiamiWebLyrics.swift
//  LyricsX
//
//  Created by Eru on 2017/7/2.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa
import Alamofire

class XiamiWebLyrics {
    
    var searchInfo: SearchInfo
    
    var serverTitle: String?
    
    var serverArtist: String?
    
    var serverAlbum: String?
    
    var lyrics: Lyrics?
    
    var requestURL: String
    
    init?(info: SearchInfo, url: String, title: String? = nil, artist: String? = nil, album: String? = nil) {
        guard !url.isEmpty else { return nil }
        searchInfo = info
        requestURL = url
        serverTitle = title
        serverArtist = artist
        serverAlbum = album
    }
}

extension XiamiWebLyrics: WebLyrics {
    var sourceInfo: LyricsSourceInfo { return .Xiami }
    var lyricsType: LyricsType { return .lrc }
}

extension XiamiWebLyrics: DownloadableWebLyrics {
    var parameters: Parameters? { return nil }
    var httpHeaders: HTTPHeaders? { return nil }
}

