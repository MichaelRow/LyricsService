//
//  GecimiSource.swift
//  LyricsX
//
//  Created by Eru on 2017/7/4.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

private let GecimiSearchURL = "http://geci.me/api/lyric/%@/%@"

public class GecimiSource {
    var requestMap = [SearchInfo : LyricsRequestContext]()
    public init() {}
}

extension GecimiSource: LyricsSource {
    public var info: LyricsSourceInfo { return .Gecimi }
}

extension GecimiSource: ConcurrentableLyricsSource {
    
    var httpMethod: HTTPMethod { return .get }
    
    var httpHeaders: HTTPHeaders? { return nil }
    
    func parameters(from info: SearchInfo) -> Parameters? { return nil }
    
    func searchURL(from info: SearchInfo) -> String {
        return String(format: GecimiSearchURL, info.title, info.artist).urlEncoding
    }
    
    func handle(data: Data, context: LyricsRequestContext, completionHandler: ([WebLyrics], LyricsError?) -> Void) {
        guard let resultArray = JSON(data)["result"].array else {
            completionHandler([], .parse)
            return
        }
        
        var lyricsArray = [WebLyrics]()
        for result in resultArray {
            guard let url = result["lrc"].string else { continue }
            let title = result["song"].string
            
            let lyrics = GecimiWebLyrics(info: context.searchInfo, url: url, title: title)
            lyricsArray.append(lyrics)
        }
        
        completionHandler(lyricsArray, nil)
    }
}

