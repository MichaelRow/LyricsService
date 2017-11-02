//
//  LrcFilter.swift
//  LyricsService
//
//  Created by Michael Row on 2017/10/29.
//  Copyright © 2017年 Michael Row. All rights reserved.
//

import Foundation
import OpenCCSwift

public class LrcFilter {
    
    public struct Filter {
        public var keyword: String
        public var ignoreCase: Bool
        public var ignoreChinese: Bool
        public var colonFilter: Bool
    }
    
    struct Context {
        var inConsiderFilter: [Filter]
        var directFilter: [Filter]
    }
    
    enum Kind {
        case keep
        case direct
        case inConsider
    }
    
    public static let shared = LrcFilter()
    
    private var filterList = [Filter]()
    
    private var colonList = [":", "："]
    
    private var chineseConverter: ChineseConverter
    
    private init() {
        chineseConverter = ChineseConverter(Simplize.taiwanPhrase)!
        loadFilter()
    }
    
    private func loadFilter() {
        guard let bundle = Bundle(identifier: "MR.LyricsService"),
              let path = bundle.path(forResource: "FilterList", ofType: "plist"),
              let filterDictionary = NSDictionary(contentsOfFile: path)
        else { return }
        
        for key in filterDictionary.allKeys {
            guard let key = key as? String,
                  let ignoreCase = filterDictionary[key] as? Bool,
                  let ignoreChinese = filterDictionary[key] as? Bool,
                  let colonFilter = filterDictionary[key] as? Bool
            else { continue }
            
            let filter = Filter(keyword: key, ignoreCase: ignoreCase, ignoreChinese: ignoreChinese, colonFilter: colonFilter)
            filterList.append(filter)
        }
    }
    
    public func filt(lyrics: Lyrics) {
        let context = filterContext(from: lyrics)
        var filtTypes = [Kind]()
        
        for line in lyrics.lines {
            let kind = filtLine(with: line.value, context: context)
            filtTypes.append(kind)
        }
        
        for (index, line) in lyrics.lines.enumerated() {
            switch filtTypes[index] {
            case .keep:
                continue
            case .direct:
                line.enable = false
            case .inConsider:
                line.enable = shouldEnable(with: index, filtTypes: filtTypes)
            }
        }
    }
    
    private func shouldEnable(with index: Int, filtTypes: [Kind]) -> Bool {
        var filtCount = 0
        
        var i = index - 1
        while i >= 0 {
            guard filtTypes[i] != .keep else { break }
            filtCount += 1
            i += 1
        }
        
        var j = index + 1
        while j < filtTypes.count {
            guard filtTypes[j] != .keep else { break }
            filtCount += 1
            j += 1
        }
        
        return filtCount >= 3 ? true : false
    }
    
    private func filterContext(from lyrics: Lyrics) -> Context {
        var inConsiderFilters = [Filter]()
        var directFilters = [Filter]()
        
        for key in lyrics.metaData.allInfo.keys {
            guard let value = lyrics.metaData.allInfo[key] else { continue }
            switch key {
            case "ti", "al":
                inConsiderFilters.append(Filter(keyword: value, ignoreCase: true, ignoreChinese: true, colonFilter: false))
            default:
                directFilters.append(Filter(keyword: value, ignoreCase: true, ignoreChinese: true, colonFilter: false))
            }
        }
        return Context(inConsiderFilter: inConsiderFilters, directFilter: directFilters)
    }
    
    private func filtLine(with lineContent: String, context: Context) -> Kind {
        for filter in filterList + context.directFilter {
            guard shouldFilt(with: lineContent, filter: filter) else { continue }
            return .direct
        }
        
        for filter in context.inConsiderFilter {
            guard shouldFilt(with: lineContent, filter: filter) else { continue }
            return .inConsider
        }
        
        return .keep
    }
    
    private func shouldFilt(with lineContent: String, filter: Filter) -> Bool {
        var finalLine = lineContent.withoutSpace
        var keyword = filter.keyword.withoutSpace
        
        if filter.colonFilter {
            var found = false
            for colon in colonList {
                guard finalLine.range(of: colon) != nil else { continue }
                found = true
                break
            }
            guard found else { return false }
        }
        
        if filter.ignoreCase {
            finalLine = finalLine.lowercased()
            keyword = keyword.lowercased()
        }
        
        if filter.ignoreChinese {
            finalLine = chineseConverter.convert(string: finalLine)
            keyword = chineseConverter.convert(string: keyword)
        }
        
        guard finalLine.range(of: keyword) != nil else { return false }
        return true
    }
}
