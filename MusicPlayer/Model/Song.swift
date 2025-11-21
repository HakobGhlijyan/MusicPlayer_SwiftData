//
//  Song.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/20/25.
//

import Foundation

struct Song: Identifiable {
    var id = UUID()
    var name: String
    var data: Data
    var artist: String?
    var coverImage: Data?
    var duration: TimeInterval?
}
