//
//  Song.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/20/25.
//

import Foundation

struct Song: Identifiable {
    let id = UUID()
    let name: String
    let data: Data
    let artist: String?
    let coverImage: Data?
    let duration: TimeInterval?
}
