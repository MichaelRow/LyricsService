//
//  NetEaseSource.swift
//  LyricsX
//
//  Created by Eru on 2017/7/7.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

private let NetEaseSearchURL = "http://music.163.com/api/search/pc?"

public class NetEaseSource {
        
    var requestMap = [SearchInfo : LyricsRequestContext]()
    
    public init() {}
}

extension NetEaseSource: LyricsSource {
    public var info: LyricsSourceInfo { return .NetEase }
}

extension NetEaseSource: ConcurrentableLyricsSource {
    
    var httpMethod: HTTPMethod { return .post }
    
    var httpHeaders: HTTPHeaders? {
        var headers = Alamofire.SessionManager.defaultHTTPHeaders
        headers["Cookie"]  = "appver=1.5.0.75771;"
        headers["Referer"] = "http://music.163.com/"
        return headers
    }
    
    func searchURL(from info: SearchInfo) -> String { return NetEaseSearchURL }
    
    func parameters(from info: SearchInfo) -> Parameters? {
        return [ "offset" : "1",
                 "limit"  : "15",
                 "type"   : "1",
                 "s"      : info.keyword ]
    }
    
    func handle(data: Data, context: LyricsRequestContext, completionHandler: ([WebLyrics], LyricsError?) -> Void) {
        guard let songArray = JSON(data)["result"]["songs"].array else {
            completionHandler([], .parse)
            return
        }
        
        var lyricsArray = [WebLyrics]()
        for songJson in songArray {
            guard let songID = songJson["id"].int else { continue }
            let title = songJson["name"].string
            let artist = songJson["artists"][0]["name"].string
            let webLyrics = NetEaseWebLyrics(info: context.searchInfo, songID: songID, title: title, artist: artist)
            lyricsArray.append(webLyrics)
        }
        
        completionHandler(lyricsArray, nil)
    }
}

