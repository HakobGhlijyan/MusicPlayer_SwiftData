//
//  Song.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/20/25.
//

import Foundation
import RealmSwift

//struct Song: Identifiable {
//    var id = UUID()
//    var name: String
//    var data: Data
//    var artist: String?
//    var coverImage: Data?
//    var duration: TimeInterval?
//}

/*
 Title
 Artist
 Album
 Year
 Genre
 Composer
 Publisher
 Track Number
 Comment
 Encoded By
 */

//Realm Version
class Song: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String
    @Persisted var data: Data
    @Persisted var artist: String?
    @Persisted var coverImage: Data?
    @Persisted var duration: TimeInterval?
    
    convenience init(name: String, data: Data, artist: String? = nil, coverImage: Data? = nil, duration: TimeInterval? = nil) {
        self.init()
        self.name = name
        self.data = data
        self.artist = artist
        self.coverImage = coverImage
        self.duration = duration
    }
}

// Realm Project package version now is 14.14.0 its work only iOS 16 +
// iOS 15 use range is 10.43.0 < 10.48.0 
