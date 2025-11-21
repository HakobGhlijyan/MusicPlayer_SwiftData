//
//  PlayerViewModel.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/21/25.
//

import SwiftUI
import Combine

final class PlayerViewModel: ObservableObject {
    @Published var songs: [Song] = [
        Song(name: "Natural", data: Data(), artist: "Imagine Dragon", coverImage: Data(), duration: 0)
    ]

}
