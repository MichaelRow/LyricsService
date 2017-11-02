//
//  XiamiSource.swift
//  LyricsX
//
//  Created by Eru on 2017/7/1.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

private let XiamiSearchURL = "http://www.xiami.com/web/search-songs"
private let XiamiLyricsURL = "http://www.xiami.com/song/playlist/id/%@"

public class XiamiSource {
    
    private var requestMap = [SearchInfo : LyricsRequestContext]()
    
    public init() {}
}

extension XiamiSource: LyricsSource {
    
    public var info: LyricsSourceInfo { return .Xiami }
    
    public func cancelSearch(info: SearchInfo) {
        guard let context = requestMap[info] else { return }
        context.cancel()
        requestMap.removeValue(forKey: info)
    }
    
    public func stopSearch() {
        requestMap.values.forEach { $0.cancel() }
        requestMap.removeAll()
    }
    
    // MARK: - WebLyrics
    
    public func search(with info: SearchInfo, completionHandler: @escaping ([WebLyrics], LyricsError?) -> Void) {
        if requestMap[info] != nil {
            cancelSearch(info: info)
        }
        
        let request = Alamofire.request(XiamiSearchURL, parameters: requestParameters(from: info))
        let context = LyricsRequestContext(info)
        context.add(request: request)
        
        context.group.enter()
        request.responseJSON { response in
            self.handleResponse(with: context, response: response)
            context.group.leave()
        }
        
        notify(with: context, completionHandler: completionHandler)
    }
    
    private func notify(with context: LyricsRequestContext, completionHandler: @escaping ([WebLyrics], LyricsError?) -> Void) {
        context.group.notify(queue: DispatchQueue.main) {
            let error = context.isCancelled ? LyricsError.userCancel : nil
            completionHandler(context.allWebLyrics, error)
            self.requestMap.removeValue(forKey: context.searchInfo)
        }
    }
    
    // MARK: - Lyrics
    
    public func search(with info: SearchInfo, inProgress: @escaping (Lyrics) -> Void, completionHandler: @escaping ([Lyrics], LyricsError?) -> Void) {
        if requestMap[info] != nil {
            cancelSearch(info: info)
        }
        
        let request = Alamofire.request(XiamiSearchURL, parameters: requestParameters(from: info))
        let context = LyricsRequestContext(info)
        context.add(request: request)
        
        context.group.enter()
        request.responseJSON { response in
            self.handleResponse(with: context, response: response)
            context.group.leave()
        }
        
        notifyWebLyricsDidComplete(with: context, inProgress: inProgress, completionHandler: completionHandler)
    }
    
    private func notifyWebLyricsDidComplete(with context: LyricsRequestContext, inProgress: @escaping (Lyrics) -> Void, completionHandler: @escaping ([Lyrics], LyricsError?) -> Void) {
        context.group.notify(queue: DispatchQueue.main) {
            guard !context.isCancelled else {
                completionHandler([], .userCancel)
                return
            }
            
            self.startLyricsDownload(with: context, inProgress: inProgress, completionHandler: completionHandler)
        }
    }
    
    private func startLyricsDownload(with context:LyricsRequestContext, inProgress: @escaping (Lyrics) -> Void, completionHandler: @escaping ([Lyrics], LyricsError?) -> Void) {
        context.allWebLyrics.forEach { webLyrics in
            requestLyrics(with: context, webLyrics: webLyrics, inProgress: inProgress)
        }
        
        context.group.notify(queue: DispatchQueue.main) {
            let error = context.isCancelled ? LyricsError.userCancel : nil
            completionHandler(context.allLyrics, error)
        }
    }
    
    private func requestLyrics(with context: LyricsRequestContext, webLyrics: WebLyrics, inProgress: @escaping (Lyrics) -> Void) {
        context.group.enter()
        let lyricsRequest = webLyrics.lyrics { lyrics in
            guard let lyrics = lyrics else {
                context.group.leave()
                return
            }
            inProgress(lyrics)
            context.allLyrics.append(lyrics)
            context.group.leave()
        }
        
        guard lyricsRequest != nil else {
            context.group.leave()
            return
        }
        context.add(request: lyricsRequest!)
    }
    
    //MARK: - Other
    
    private func requestParameters(from info: SearchInfo) -> Parameters {
        return ["key" : info.keyword]
    }
    
    private func handleResponse(with context: LyricsRequestContext, response: DataResponse<Any>) {
        guard case .success(let value) = response.result,
              let infoDictArray = JSON(value).array
        else { return }
        
        for infoDict in infoDictArray {
            requestSongInfo(with: context, infoDict: infoDict)
        }
    }
    
    private func requestSongInfo(with context: LyricsRequestContext, infoDict: JSON) {
        guard let songID = infoDict["id"].string,
              let url = URL(string: String(format: XiamiLyricsURL, songID).urlEncoding),
              !context.isCancelled
        else { return }
        
        let request = Alamofire.request(url)
        context.add(request: request)
        
        context.group.enter()
        request.responseData { response in
            self.handleSongInfoResponse(with: context, response: response)
            context.group.leave()
        }
    }
    
    private func handleSongInfoResponse(with context: LyricsRequestContext, response: DataResponse<Data>) {
        guard case .success(let data) = response.result,
              let xiamiLyrics = XiamiXMLParser().parse(data: data, info: context.searchInfo)
        else { return }
        context.allWebLyrics.append(xiamiLyrics)
    }
}
