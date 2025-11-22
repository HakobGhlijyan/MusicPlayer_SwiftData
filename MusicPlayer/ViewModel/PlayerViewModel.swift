//
//  PlayerViewModel.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/21/25.
//

import SwiftUI
import Combine
import AVKit

final class PlayerViewModel: ObservableObject {
    @Published var songs: [Song] = []
    @Published var audioPlayer: AVAudioPlayer?
    @Published var isPlaying: Bool = false
    @Published var currentIndex: Int?
    
    var currentSong: Song? {
        guard let currentIndex = currentIndex, songs.indices.contains(currentIndex) else {
            return nil
        }
        return songs[currentIndex]
    }

    func playAudio(song: Song) {
        do {
            self.audioPlayer = try AVAudioPlayer(data: song.data)
            self.audioPlayer?.play()
            isPlaying = true
            if let index = songs.firstIndex(where: { $0.id == song.id }) {
                currentIndex = index
            }
        } catch {
            print("Error \(#function) - \(error.localizedDescription)")
        }
    }
    
    func playPause() {
        if isPlaying {
            self.audioPlayer?.pause()
        } else {
            self.audioPlayer?.play()
        }
        isPlaying.toggle()
    }
    
    //Converter
    func durationFormatted(duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration) ?? "0:00"
    }
}

//ALTERNATIVE
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

extension TimeInterval {
    static let mmssFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.minute, .second]
        f.unitsStyle = .positional
        f.zeroFormattingBehavior = .pad
        return f
    }()
    
    var mmSS: String {
        TimeInterval.mmssFormatter.string(from: self) ?? "0:00"
    }
}
