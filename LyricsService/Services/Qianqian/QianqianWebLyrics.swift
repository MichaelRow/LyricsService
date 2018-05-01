//
//  QianqianWebLyrics.swift
//  LyricsX
//
//  Created by Eru on 2017/7/1.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa
import Alamofire

class QianqianWebLyrics {
    
    var searchInfo: SearchInfo
    
    var serverTitle: String?
    
    var serverArtist: String?
    
    var serverAlbum: String?
    
    private(set) var requestURL: String
    
    var lyrics: Lyrics?
    
    init(info: SearchInfo, url: String, title: String? = nil, artist: String? = nil, album: String? = nil) {
        searchInfo = info
        requestURL = url
        serverTitle = title
        serverArtist = artist
        serverAlbum = album
    }
}

extension QianqianWebLyrics: WebLyrics {
    var lyricsType: LyricsType { return .lrc }
    var sourceInfo: LyricsSourceInfo { return .Qianqian }
}

extension QianqianWebLyrics: DownloadableWebLyrics {
    var parameters: Parameters? { return nil }
    var httpHeaders: HTTPHeaders? { return nil }
}

