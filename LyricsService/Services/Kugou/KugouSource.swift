//
//  KugouSource.swift
//  LyricsX
//
//  Created by Eru on 2017/6/18.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

private let KugouSearchURL = "http://lyrics.kugou.com/search"

public class KugouSource {
    
    var requestMap = [SearchInfo : LyricsRequestContext]()
    
    public init() {}
}

extension KugouSource: LyricsSource {
    public var info: LyricsSourceInfo { return .Kugou }
}

extension KugouSource: ConcurrentableLyricsSource {
    
    var httpMethod: HTTPMethod { return .get }
    
    var httpHeaders: HTTPHeaders? { return nil }
    
    func searchURL(from info: SearchInfo) -> String { return KugouSearchURL }
    
    func parameters(from info: SearchInfo) -> Parameters? {
        return [ "ver"      : "1",
                 "man"      : "yes",
                 "client"   : "pc",
                 "duration" : info.duration.description,
                 "keyword"  : info.keyword ]
    }
    
    func handle(data: Data, context: LyricsRequestContext, completionHandler: ([WebLyrics], LyricsError?) -> Void) {
        guard let candidates = JSON(data)["candidates"].array else {
            completionHandler([], .parse)
            return
        }
        
        var lyricsArray = [WebLyrics]()
        for candidate in candidates {
            guard let accessKey = candidate["accesskey"].string,
                  let songID = candidate["id"].string
            else { continue }
            let title = candidate["song"].string
            let artist = candidate["singer"].string
            let webLyrics = KugouWebLyrics(info: context.searchInfo, accessKey: accessKey, songID: songID, title: title, artist: artist)
            
            lyricsArray.append(webLyrics)
        }
        
        completionHandler(lyricsArray, nil)
    }
}


