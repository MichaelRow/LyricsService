//
//  LyricsSourceManager.swift
//  LyricsService
//
//  Created by Eru on 2017/10/7.
//  Copyright © 2017年 Michael Row. All rights reserved.
//

import Foundation

public class LyricsSourceManager {
    
    private var lyricsSources = [LyricsSource]()
    
    private var pickingMap = [SearchInfo : PickingSearchContext]()
            
    public var managedSourceNames: [LyricsSourceInfo] {
        return lyricsSources.map { $0.info }
    }
    
    public init() {}
    
    public func add(sourceNames: [LyricsSourceInfo]) {
        sourceNames.forEach { add(sourceName: $0) }
    }
    
    public func add(sourceName: LyricsSourceInfo) {
        guard !managedSourceNames.contains(sourceName) else { return }
        
        let source = LyricsSourceFactory.source(with: sourceName)
        lyricsSources.append(source)
    }
    
    public func remove(sourceNames: [LyricsSourceInfo]) {
        var newSources = [LyricsSource]()
        lyricsSources.forEach {
            guard !sourceNames.contains($0.info) else {
                $0.stopSearch()
                return
            }
            newSources.append($0)
        }
        lyricsSources = newSources
    }
    
    public func removeAllSources() {
        lyricsSources.forEach { $0.stopSearch() }
        lyricsSources.removeAll()
    }
    
    /// 取消搜索
    public func cancelSearch(info: SearchInfo) {
        lyricsSources.forEach { $0.cancelSearch(info: info) }
    }
    
    /// 停止搜索
    public func stopSearch() {
        lyricsSources.forEach { $0.stopSearch() }
    }
    
    //MARK: - Normal Search
    
    public func searchWebLyrics(with info: SearchInfo, inProgress:(([WebLyrics]) -> Void)?, completion:@escaping ([WebLyrics], LyricsError?) -> Void) {
        let group = DispatchGroup()
        var allLyrics = [WebLyrics]()
        var searchError: LyricsError?
        
        lyricsSources.forEach { source in
            group.enter()
            
            source.search(with: info, completionHandler: { lyricsArray, error in
                guard error == nil else {
                    searchError = error
                    group.leave()
                    return
                }
                
                allLyrics.append(contentsOf: lyricsArray)
                inProgress?(lyricsArray)
                
                group.leave()
            })
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion(allLyrics, searchError)
        }
    }
    
    //MARK: - Picking Search
    
    public func pickingSearchLyrics(with info: SearchInfo, option:Lyrics.Option, inProgress:((Lyrics) -> Void)?, completion: @escaping (Lyrics?, LyricsError?) -> Void) {
        
        let context = PickingSearchContext(info, option: option)
        pickingMap[info] = context
        
        searchWebLyrics(with: info, inProgress: nil) { webLyrics, error in
            guard !context.isCancelled else {
                completion(nil, .userCancel)
                return
            }
            
            guard error != nil else {
                completion(nil, error)
                return
            }
            
            context.allWebLyrics = webLyrics
            LyricsPicker.pickLyrics(with: context, inProgress: { lyrics in
                guard !context.isCancelled else { return }
                inProgress?(lyrics)
            }, completion: { lyrics, pickingError  in
                let error = (context.isCancelled ? LyricsError.userCancel : nil) ?? pickingError
                completion(lyrics, error)
            })
        }
    }
    
    //MARK: - Fully Search
    
    public func searchLyrics(with info: SearchInfo, inProgress: ((Lyrics) -> Void)?, completion: @escaping ([Lyrics], LyricsError?) -> Void) {
        let group = DispatchGroup()
        var allLyrics = [Lyrics]()
        var searchError: LyricsError?
        
        lyricsSources.forEach { source in
            group.enter()
            
            source.search(with: info, inProgress: { lyrics in
                allLyrics.append(lyrics)
                inProgress?(lyrics)
            }, completionHandler: { lyricsArray, error in
                if error != nil {
                    searchError = error
                }
                group.leave()
            })
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion(allLyrics, searchError)
        }
    }
}
