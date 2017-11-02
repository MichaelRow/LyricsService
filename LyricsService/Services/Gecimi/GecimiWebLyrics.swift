//
//  GecimiWebLyrics.swift
//  LyricsX
//
//  Created by Eru on 2017/7/4.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa
import Alamofire

class GecimiWebLyrics {

    var searchInfo: SearchInfo
    
    var serverTitle: String?
    
    var serverArtist: String?
    
    var serverAlbum: String?
    
    var lyrics: Lyrics?
    
    private(set) var requestURL: String
    
    init(info: SearchInfo, url: String, title: String? = nil, artist: String? = nil, album: String? = nil) {
        searchInfo = info
        requestURL = url
    }
}

extension GecimiWebLyrics: WebLyrics {
    var sourceInfo: LyricsSourceInfo { return .Gecimi }
    var lyricsType: LyricsType { return .Lrc }
}

extension GecimiWebLyrics: DownloadableWebLyrics {
    var parameters: Parameters? { return nil }
    var httpHeaders: HTTPHeaders? { return nil }
}

