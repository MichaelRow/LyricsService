//
//  QQSource.swift
//  LyricsX
//
//  Created by Eru on 2017/7/5.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

private let QQSearchURL = "http://c.y.qq.com/soso/fcgi-bin/client_search_cp?"

public class QQSource {
    
    var requestMap = [SearchInfo : LyricsRequestContext]()
    
    public init() {}
}

extension QQSource: LyricsSource {
    public var info: LyricsSourceInfo { return .QQMusic }
}

extension QQSource: ConcurrentableLyricsSource {
    
    var httpMethod: HTTPMethod { return .get }
    
    var httpHeaders: HTTPHeaders? { return nil }
    
    func parameters(from info: SearchInfo) -> Parameters? { return nil }
    
    func searchURL(from info: SearchInfo) -> String {
        let url = QQSearchURL + "w=" + info.keyword
        return url.urlEncoding
    }
    
    func handle(data: Data, context: LyricsRequestContext, completionHandler: ([WebLyrics], LyricsError?) -> Void) {
        guard let songs = JSON(data.dropFirst(9).dropLast())["data"]["song"]["list"].array else {
            completionHandler([], .parse)
            return
        }
        
        var lyricsArray = [WebLyrics]()
        for song in songs {
            guard let songmid = song["songmid"].string else { return }
            let title = song["songname"].string
            let artist = song["singer"][0]["name"].string
            let album = song["albumname"].string
            
            let webLyrics = QQWebLyrics(info: context.searchInfo, id: songmid, title: title, artist: artist, album: album)
            lyricsArray.append(webLyrics)
        }

        completionHandler(lyricsArray, nil)
    }
}

