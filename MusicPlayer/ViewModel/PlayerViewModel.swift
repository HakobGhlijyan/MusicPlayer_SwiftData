//
//  PlayerViewModel.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/21/25.
//

import SwiftUI
import Combine
import AVKit

final class PlayerViewModel: NSObject, ObservableObject {
    @Published var songs: [Song] = []
    @Published var audioPlayer: AVAudioPlayer?
    @Published var isPlaying: Bool = false
    @Published var currentIndex: Int?
    
    @Published var currentTime: TimeInterval = 0.0
    @Published var totalTime: TimeInterval = 0.0
    
    var currentSong: Song? {
        guard let currentIndex = currentIndex, songs.indices.contains(currentIndex) else {
            return nil
        }
        return songs[currentIndex]
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

extension PlayerViewModel: AVAudioPlayerDelegate {
    //Delegate FUNC
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag { forward() }
    }
}

extension PlayerViewModel {
    func playAudio(song: Song) {
        do {
            self.audioPlayer = try AVAudioPlayer(data: song.data)
            self.audioPlayer?.delegate = self
            self.audioPlayer?.play()
            isPlaying = true
            totalTime = audioPlayer?.duration ?? 0.0
            
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
    
    func stop() {
        self.audioPlayer?.stop()
        self.audioPlayer = nil
        isPlaying = false
    }
    
    func forward() {
        guard let currentIndex = currentIndex else { return }
        let nextIndex = (currentIndex + 1 < songs.count) ? currentIndex + 1 : 0
        playAudio(song: songs[nextIndex])
    }
    
    func backward() {
        guard let currentIndex = currentIndex else { return }
        let backIndex = currentIndex > 0 ? currentIndex - 1 : songs.count - 1
        playAudio(song: songs[backIndex])
    }
    
    func seekTime(time: TimeInterval) {
        audioPlayer?.currentTime = time
    }
    
    func updateProgress() {
        guard let audioPlayer = audioPlayer else { return }
        currentTime = audioPlayer.currentTime
    }
    
    func delete(offsets: IndexSet) {
        if let first = offsets.first {
            stop()
            songs.remove(at: first)
        }
    }
}
