//
//  NetEaseWebLyrics.swift
//  LyricsX
//
//  Created by Eru on 2017/7/7.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa
import Alamofire

private let NetEaseLyricsURL = "http://music.163.com/api/song/lyric?"

class NetEaseWebLyrics {
    
    var searchInfo: SearchInfo
    
    var serverTitle: String?
        
    var serverArtist: String?
    
    var serverAlbum: String?
    
    var lyrics: Lyrics?
    
    private var songID: Int
    
    init(info: SearchInfo, songID: Int, title: String? = nil, artist: String? = nil) {
        self.searchInfo = info
        self.songID = songID
        self.serverTitle = title
        self.serverArtist = artist
    }
}

extension NetEaseWebLyrics: WebLyrics {
    var sourceInfo: LyricsSourceInfo { return .NetEase }
    var lyricsType: LyricsType { return .netEase }
}

extension NetEaseWebLyrics: DownloadableWebLyrics {
    
    var requestURL: String { return NetEaseLyricsURL }
    
    var httpHeaders: HTTPHeaders? { return nil }
    
    var parameters: Parameters? {
        return [ "os" : "pc",
                 "lv" : "-1",
                 "kv" : "-1",
                 "tv" : "-1",
                 "id" : songID ]
    }
    
    func handle(response: String) -> Lyrics? { return lyricsType.decoder.decode(response) }
}

