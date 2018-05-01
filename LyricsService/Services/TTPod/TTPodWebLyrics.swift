//
//  TTPodWebLyrics.swift
//  LyricsX
//
//  Created by Eru on 2017/7/4.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa

class TTPodWebLyrics {

    var searchInfo: SearchInfo
    
    var serverTitle: String?
    
    var serverArtist: String?
    
    var serverAlbum: String?
    
    var lyrics: Lyrics
    
    init?(info: SearchInfo, lyricsContent: String) {
        self.searchInfo = info
        guard let lyrics = LrcDecoder.shared.decode(lyricsContent) else { return nil }
        self.lyrics = lyrics
    }
}

extension TTPodWebLyrics: WebLyrics {
    var sourceInfo: LyricsSourceInfo { return .TTPod }
    var lyricsType: LyricsType { return .lrc }
}

extension TTPodWebLyrics: NowAvailableWebLyrics {}

