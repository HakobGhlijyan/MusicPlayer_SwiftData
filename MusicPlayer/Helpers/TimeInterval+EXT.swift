//
//  TimeInterval+EXT.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/25/25.
//

import SwiftUI

//ALTERNATIVE -> alternative fir use in ViewModel converter
//extension TimeInterval {
//    var mmSS: String {
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.minute, .second]
//        formatter.unitsStyle = .positional
//        formatter.zeroFormattingBehavior = .pad
//        return formatter.string(from: self) ?? "0:00"
//    }
//}
//
//Text(song.duration?.mmSS ?? "0:00").songTimeFont()
//
//extension TimeInterval {
//    static let mmssFormatter: DateComponentsFormatter = {
//        let f = DateComponentsFormatter()
//        f.allowedUnits = [.minute, .second]
//        f.unitsStyle = .positional
//        f.zeroFormattingBehavior = .pad
//        return f
//    }()
//
//    var mmSS: String {
//        TimeInterval.mmssFormatter.string(from: self) ?? "0:00"
//    }
//}
