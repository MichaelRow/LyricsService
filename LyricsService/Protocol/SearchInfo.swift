//
//  SearchInfo.swift
//  LyricsX
//
//  Created by Eru on 2017/8/16.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Foundation

public struct SearchInfo {
    
    public var title: String
    public var artist: String
    /// The duration of the song. In millisecond.
    public var duration: Int
    
    public var keyword: String {
        return title + " " + artist
    }
    
    public init(title: String, artist: String, duration: Int) {
        self.title = title
        self.artist = artist
        self.duration = duration
    }
}

extension SearchInfo: Equatable {
    
    public static func ==(lhs: SearchInfo, rhs: SearchInfo) -> Bool {
        guard lhs.title == rhs.title,
              lhs.artist == rhs.artist,
              lhs.duration == rhs.duration
        else { return false }
        
        return true
    }
}

extension SearchInfo: Hashable {
    
    public var hashValue: Int {
        return (title + artist + duration.description).hashValue
    }
}
