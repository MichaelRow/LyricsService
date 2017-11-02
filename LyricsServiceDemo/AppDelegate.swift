//
//  AppDelegate.swift
//  LyricsServiceDemo
//
//  Created by Eru on 2017/10/5.
//  Copyright © 2017年 Michael Row. All rights reserved.
//

import Cocoa
import LyricsService

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    let source = QQSource()
    
    let manager = LyricsSourceManager()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        manager.add(sourceNames: [.Gecimi,.Kugou,.NetEase,.QQMusic,.Qianqian,.TTPod])
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func oneSourceSearch(_ sender: Any?) {
        let info = SearchInfo(title:"only my railgun", artist:"fripside", duration:257000)
        
        source.search(with: info, inProgress: { (lyrics) in
            print(lyrics.lyricsValue)
        }) { (lyricsArray, error) in
            NSLog("")
        }
    }
    
    @IBAction func allSourceSearch(_ sender: Any?) {
        let info = SearchInfo(title:"only my railgun", artist:"fripside", duration:257000)
        manager.searchLyrics(with: info, inProgress: { (webLyrics) in
            NSLog("")
        }) { (webLyricsArray, error) in
            NSLog("")
        }
    }
    
    @IBAction func pick(_ sender: Any?) {
        let info = SearchInfo(title:"only my railgun", artist:"fripside", duration:257000)
        manager.pickingSearchLyrics(with: info, option: [.karaoke,.translate,.romaji], inProgress: { (lyrics) in
            print(lyrics.lyricsValue)
        }) { (lyrics, error) in
            print(lyrics?.lyricsValue)
        }
    }
    
    @IBAction func open(_ sender: Any?) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.isExtensionHidden = false
        panel.allowedFileTypes = ["lrcx"]
        panel.begin { response in
            guard response == .OK,
                  let url = panel.url,
                  let text = try? String(contentsOf: url),
                  let lyrics = LrcxDecoder.shared.decode(text)
            else { return }
            
            print(lyrics.lyricsValue)
            print(lyrics.romajiValue)
        }
    }
}

