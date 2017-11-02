//
//  ConcurrentableLyricsSource.swift
//  LyricsService
//
//  Created by Eru on 2017/10/6.
//  Copyright © 2017年 Michael Row. All rights reserved.
//

import Foundation
import Alamofire

protocol ConcurrentableLyricsSource: LyricsSource {
    var requestMap: [SearchInfo : LyricsRequestContext] { get set }
    var httpMethod: HTTPMethod { get }
    var httpHeaders: HTTPHeaders? { get }
    func searchURL(from info: SearchInfo) -> String
    func parameters(from info: SearchInfo) -> Parameters?
    
    /// Process the server data and pass WebLyricsList back to the completion handler.
    ///
    /// - Parameters:
    ///   - data: The server data.
    ///   - searchInfo: The info that starts the search.
    ///   - completionHandler: A closure you must call when everything has been done.
    func handle(data: Data, context: LyricsRequestContext, completionHandler: ([WebLyrics], LyricsError?) -> Void)
}

extension ConcurrentableLyricsSource {
    
    public func cancelSearch(info: SearchInfo) {
        guard let context = requestMap[info] else { return }
        context.cancel()
        requestMap.removeValue(forKey: info)
    }
    
    public func stopSearch() {
        requestMap.values.forEach { $0.cancel() }
        requestMap.removeAll()
    }
    
    public func search(with info: SearchInfo, completionHandler: @escaping ([WebLyrics], LyricsError?) -> Void) {
        if requestMap[info] != nil {
            cancelSearch(info: info)
        }
        
        let request = Alamofire.request(searchURL(from: info), method: httpMethod, parameters: parameters(from: info), headers: httpHeaders)
        let context = LyricsRequestContext(info)
        context.add(request: request)
        requestMap[info] = context
        
        request.responseData(completionHandler: { response in
            guard case .success(let data) = response.result else {
                let error = context.isCancelled ? LyricsError.userCancel : LyricsError.network
                completionHandler([], error)
                return
            }
            
            self.handle(data: data, context: context, completionHandler: completionHandler)
            
            self.requestMap.removeValue(forKey: info)
        })
    }
    
    // MARK: - Fully Search
    
    public func search(with info: SearchInfo, inProgress: @escaping (Lyrics) -> Void, completionHandler: @escaping ([Lyrics], LyricsError?) -> Void) {
        if requestMap[info] != nil {
            cancelSearch(info: info)
        }
        
        let context = LyricsRequestContext(info)
        requestMap[info] = context
        
        requestLyrics(context, inProgress: inProgress)
        notify(with: context, completionHandler: completionHandler)
    }
    
    private func notify(with context: LyricsRequestContext, completionHandler: @escaping ([Lyrics], LyricsError?) -> Void) {
        context.group.notify(queue: DispatchQueue.main) {
            let error = context.isCancelled ? LyricsError.userCancel : nil
            completionHandler(context.allLyrics, error)
            self.requestMap.removeValue(forKey: context.searchInfo)
        }
    }
    
    private func requestLyrics(_ context: LyricsRequestContext, inProgress: @escaping (Lyrics) -> Void) {
        let request = Alamofire.request(searchURL(from: context.searchInfo), method: httpMethod, parameters: parameters(from: context.searchInfo), headers: httpHeaders)
        context.add(request: request)
        
        context.group.enter()
        request.responseData(completionHandler: { response in
            guard case .success(let data) = response.result else {
                context.group.leave()
                return
            }
            
            self.handle(data: data, context: context, inProgress: inProgress)
            
            context.group.leave()
        })
    }
    
    private func handle(data: Data, context: LyricsRequestContext, inProgress: @escaping (Lyrics) -> Void) {
        self.handle(data: data, context: context) { lyricsArray , error in
            lyricsArray.forEach { webLyrics in
                self.download(webLyrics: webLyrics, context: context, inProgress: inProgress)
            }
        }
    }
    
    private func download(webLyrics: WebLyrics, context: LyricsRequestContext, inProgress: @escaping (Lyrics) -> Void) {
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
}
