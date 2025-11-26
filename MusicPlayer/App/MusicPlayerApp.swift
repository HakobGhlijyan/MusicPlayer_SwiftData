//
//  MusicPlayerApp.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/20/25.
//

import SwiftUI
import SwiftData

@main
struct MusicPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            let _ = print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path)   // iOS <16

            PlayerView()
        }
        .modelContainer(for: Song.self)
    }
}
