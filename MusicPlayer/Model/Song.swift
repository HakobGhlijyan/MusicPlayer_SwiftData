//
//  Song.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/20/25.
//

import Foundation
import SwiftData

@Model
final class Song {
    var name: String
    @Attribute(.externalStorage) var data: Data
    var artist: String?
    var coverImage: Data?
    var duration: Double?

    init(name: String, data: Data, artist: String? = nil, coverImage: Data? = nil, duration: Double? = nil) {
        self.name = name
        self.data = data
        self.artist = artist
        self.coverImage = coverImage
        self.duration = duration
    }
}
