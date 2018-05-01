//
//  QQWebLyrics.swift
//  LyricsX
//
//  Created by Eru on 2017/7/5.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

private let QQLyricsURL = "http://c.y.qq.com/lyric/fcgi-bin/fcg_query_lyric_new.fcg?g_tk=5381&songmid=%@"

class QQWebLyrics {

    var searchInfo: SearchInfo
    
    var serverTitle: String?
    
    var serverArtist: String?
    
    var serverAlbum: String?
    
    var lyrics: Lyrics?
    
    private var songID: String
    
    init(info: SearchInfo, id: String, title: String? = nil, artist: String? = nil, album: String? = nil) {
        searchInfo = info
        songID = id
        serverTitle = title
        serverArtist = artist
        serverAlbum = album
    }
}

extension QQWebLyrics: WebLyrics {
    var sourceInfo: LyricsSourceInfo { return .QQMusic }
    var lyricsType: LyricsType { return .lrc }
}

extension QQWebLyrics: DownloadableWebLyrics {
    
    var requestURL: String {
        return String(format: QQLyricsURL, songID).urlEncoding
    }
    
    var parameters: Parameters? { return nil }
    
    var httpHeaders: HTTPHeaders? {
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        headers["Referer"] = "y.qq.com/portal/player.html"
        return headers
    }
    
    func handle(response: String) -> Lyrics? {
        guard response.count >= 19 else { return nil }
        
        let startIndex = response.index(response.startIndex, offsetBy: 18)
        let endIndex = response.index(response.endIndex, offsetBy: -1)
        let json = JSON(parseJSON: String(response[startIndex ..< endIndex]))
        
        guard let lyricsData = Data(base64Encoded: json["lyric"].stringValue),
              let lyricsContent = String(data: lyricsData, encoding: .utf8)
        else { return nil }
        let lyrics = LrcDecoder.shared.decode(lyricsContent)
        
        guard let transData = Data(base64Encoded: json["trans"].stringValue),
              let transContent = String(data: transData, encoding: .utf8),
              let lyricsTrans = LrcDecoder.shared.decode(transContent)
        else { return lyrics }
        
        lyrics?.merge(lyrics: lyricsTrans, newOption: .translate)
        return lyrics
    }
}
