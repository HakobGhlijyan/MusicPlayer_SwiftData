//
//  PlayerViewModel.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/21/25.
//

import SwiftUI
import SwiftData
import Combine
import AVKit

final class PlayerViewModel: NSObject, ObservableObject {
    private var songsDB: [Song] = []
    @Published var audioPlayer: AVAudioPlayer?
    @Published var isPlaying: Bool = false
    @Published var currentIndex: Int?
    
    @Published var currentTime: TimeInterval = 0.0
    @Published var totalTime: TimeInterval = 0.0
    
    var currentSong: Song? {
        guard let currentIndex = currentIndex, songsDB.indices.contains(currentIndex) else {
            return nil
        }
        return songsDB[currentIndex]
    }
        
    func updateSongs(_ newSongs: [Song]) {
        self.songsDB = newSongs
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
            
            if let index = songsDB.firstIndex(where: { $0.id == song.id }) {
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
        currentIndex = nil
        isPlaying = false
    }
    
    func forward() {
        guard let currentIndex = currentIndex else { return }
        let nextIndex = (currentIndex + 1 < songsDB.count) ? currentIndex + 1 : 0
        playAudio(song: songsDB[nextIndex])
    }
    
    func backward() {
        guard let currentIndex = currentIndex else { return }
        let backIndex = currentIndex > 0 ? currentIndex - 1 : songsDB.count - 1
        playAudio(song: songsDB[backIndex])
    }
    
    func seekTime(time: TimeInterval) {
        audioPlayer?.currentTime = time
    }
    
    func updateProgress() {
        guard let audioPlayer = audioPlayer else { return }
        currentTime = audioPlayer.currentTime
    }
    
    func deleteSongs(_ songsToDelete: [Song], context: ModelContext) {
        for song in songsToDelete {
            if currentSong?.id == song.id {
                stop()
            }
            context.delete(song)
        }
    }
}
